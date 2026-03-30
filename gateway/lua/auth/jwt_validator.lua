local jwt = require("resty.jwt")
local cjson = require("cjson")

local secret = "your-secret-key"
local payload = {
    sub = "user123",
    name = "John Doe",
    iat = os.time(),
    exp = os.time() + 3600  -- 1 hour expiration
}

-- Encode JWT
local token = jwt:sign(secret, {
    header = { typ = "JWT", alg = "HS256" },
    payload = payload
})

-- Decode and verify JWT
local decoded, err = jwt:verify(secret, token)
if decoded.verified then
    ngx.say("Verified payload: ", cjson.encode(decoded.payload))
else
    ngx.say("Verification failed: ", err)
end