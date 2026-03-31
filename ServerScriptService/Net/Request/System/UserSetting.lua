local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)

local UserSetting = {}

local InfoTemplete = {
	["UserSetting"] = {
		["Key"] = true,
	}
}

function LoadInfo(player)
	local saveInfo = PlayerPrefs:GetModule(player, "UserSetting")
	return saveInfo
end

function UserSetting:GetInfo(player)
	local saveInfo = LoadInfo(player)
	return saveInfo
end

function UserSetting:GetValue(player, param)
	local key = param.Key
	local defaultValue = param.DefaultValue or nil
	local saveInfo = LoadInfo(player)
	local value = saveInfo[key]
	if value == nil then
		saveInfo[key] = defaultValue
		value = defaultValue
	end
	
	return value
end

function UserSetting:SetValue(player, param)
	local key = param.Key
	local value = param.Value
	local saveInfo = LoadInfo(player)
	saveInfo[key] = value
	return true
end

return UserSetting
