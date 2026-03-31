local ConfigService = game:GetService("ConfigService")

local ServerConfigManager = {}

local ConfigSnapshot = ConfigService:GetConfigAsync()

function ServerConfigManager:GetValue(key, defaultValue)
	if ConfigSnapshot == nil then return defaultValue end
	local value = ConfigSnapshot:GetValue(key)
	if value == nil then return defaultValue end
	return value
end

return ServerConfigManager
