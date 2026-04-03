local redis = require 'resty.redis'

local _F = {}
local tier = {
    basic = 10,
    plus = 30,
    premium = 100
}

-- Redis connection helper
local function get_redis()
    local red = redis:new()
    red:set_timeout(1000) -- 1 second timeout

    local ok, err = red:connect('127.0.0.1', 6379)
    if not ok then
        ngx.log(ngx.ERR, 'Redis connection failed: ', err)
        return nil, err
    end

    return red
end

-- Return connection to pool instead of closing
local function close_redis(red)
    local ok, err = red:set_keepalive(10000, 100) -- 10s idle, 100 pool size
    if not ok then
        ngx.log(ngx.WARN, 'Failed to set keepalive: ', err)
        red:close()
    end
end

-- Main rate limit checker
function _F.CheckLimit(user_id, user_tier)
    local red, err = get_redis()
    if not red then
        -- Fail open or closed depending on your policy
        ngx.status = 503
        ngx.say('service unavailable')
        return ngx.exit(503)
    end

    -- Build a unique Redis key per user (resets every 60s window)
    local window = math.floor(ngx.now() / 60)
    local redis_key = string.format('ratelimit:%s:%d', user_id, window)
    -- Atomically increment usage counter
    local used, err = red:incr(redis_key)
    if not used then
        ngx.log(ngx.ERR, 'Redis INCR failed', err)
        close_redis(red)
        ngx.status = 503
        ngx.say('service unavailable')
        return ngx.exit(503)
    end
    -- Set TTL only on the first request in this window
    if used == 1 then
        red:expire(redis_key, 60)
    end
    -- Resolve the limit for this tier
    local limit = tier[user_tier] or tier['basic']
    -- Set informational headers
    ngx.header['X-RateLimit-Limit'] = limit
    ngx.header['X-RateLimit-Remaining'] = math.max(0, limit - used)
    ngx.header['X-RateLimit-Used'] = used
    close_redis(red)
    -- Block if over limit
    if used > limit then
        ngx.status = 429
        ngx.header['Retry-After'] = 60 - (ngx.now() % 60)
        ngx.say('too many requests')
        return ngx.exit(429)
    end
end

return _F
