-- lua/auth/init.lua

local jwt_validator = require "auth.jwt_validator"
-- local blacklist     = require "auth.blacklist"
-- local refresh       = require "auth.refresh_token"

local _M = {}

-- ── from jwt_validator.lua ────────────────────────────────────────
_M.sign         = jwt_validator.sign
_M.verify       = jwt_validator.verify
_M.require_auth = jwt_validator.require_auth

-- ── from blacklist.lua ────────────────────────────────────────────
-- _M.revoke      = blacklist.revoke
-- _M.is_revoked  = blacklist.is_revoked

-- ── from refresh_token.lua ────────────────────────────────────────
-- _M.refresh     = refresh.refresh

return _M