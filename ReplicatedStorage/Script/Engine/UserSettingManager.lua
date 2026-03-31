local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)

local UserSettingManager = {}

local CacheInfo = nil

local function GetInfo()
	local result = NetClient:RequestWait("UserSetting", "GetInfo")
	return result
end

local function GetValue(key, defaultValue)
	local result = NetClient:RequestWait("UserSetting", "GetValue", {
		Key = key,
		DefaultValue = defaultValue
	})
	
	return result
end

local function SetValue(key, value)
	NetClient:Request("UserSetting", "SetValue", {
		Key = key,
		Value = value
	})
end

-- TOD....

return UserSettingManager
