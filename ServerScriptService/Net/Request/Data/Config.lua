local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)

local Config = {}

function Config:GetDataList(player, param)
	local configName = param.ConfigName
	local dataList = ConfigManager:GetDataList(configName)
	return dataList
end

function Config:GetRawData(player, param)
	local configName = param.ConfigName
	local rawData = ConfigManager:LoadRawData(configName)
	return rawData
end


return Config
