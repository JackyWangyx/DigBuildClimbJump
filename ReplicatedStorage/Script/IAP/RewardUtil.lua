local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local BigNumber = require(game.ReplicatedStorage.ScriptAlias.BigNumber)

local Define = require(game.ReplicatedStorage.Define)

local RewardUtil = {}

function RewardUtil:ProcessInfoList(infoList)
	local getCoinFactor = NetClient:RequestWait("Player", "GetGamePropertyValue", { Property = Define.PlayerProperty.GET_COIN_FACTOR })
	for index, info in ipairs(infoList) do
		if info.RewardType and info.RewardType == "Coin" then
			local value = math.round(info.RewardCount * getCoinFactor)
			local text = BigNumber:Format(value)
			info.Description = "$" .. text
		end
	end
end

return RewardUtil
