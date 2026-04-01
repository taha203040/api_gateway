-- lua/auth/jwt_validator.lua

local jwt        = require "resty.jwt"
local validators = require "resty.jwt-validators"

local SECRET = "your-256-bit-secret"

local _M = {}

-- ─── Sign ─────────────────────────────────────────────────────────
function _M.sign(user_id, role)
    return jwt:sign(SECRET, {
        header = { typ = "JWT", alg = "HS256" },
        payload = {
            sub  = user_id,
            role = role,
            iat  = ngx.time(),
            exp  = ngx.time() + 3600,
            nbf  = ngx.time(),
            iss  = "my-service",
        }
    })
end

-- ─── Verify ───────────────────────────────────────────────────────
function _M.verify(token)
    local claim_spec = {
        exp = validators.is_not_expired(),
        nbf = validators.is_not_before(),
        iss = validators.equals("my-service"),
        sub = validators.required(),
    }

    local jwt_obj = jwt:verify(SECRET, token, claim_spec)

    if not jwt_obj.verified then
        return nil, jwt_obj.reason
    end

    return jwt_obj.payload, nil
end

-- ─── Middleware ───────────────────────────────────────────────────
function _M.require_auth(required_role)
    local cjson       = require "cjson"
    local auth_header = ngx.req.get_headers()["Authorization"]

    if not auth_header then
        ngx.status = 401
        ngx.say(cjson.encode({ error = "missing Authorization header" }))
        return ngx.exit(401)
    end

    local token = auth_header:match("Bearer%s+(.+)")
    if not token then
        ngx.status = 401
        ngx.say(cjson.encode({ error = "invalid Authorization format" }))
        return ngx.exit(401)
    end

    local claims, err = _M.verify(token)
    if not claims then
        ngx.status = 401
        ngx.say(cjson.encode({ error = err }))
        return ngx.exit(401)
    end

    if required_role and claims.role ~= required_role then
        ngx.status = 403
        ngx.say(cjson.encode({ error = "forbidden" }))
        return ngx.exit(403)
    end

    ngx.req.set_header("X-User-Id",   claims.sub)
    ngx.req.set_header("X-User-Role", claims.role)
end

return _M  -- ← must return