local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local Define = require(game.ReplicatedStorage.Define)

local IAPProperty = {}

local PropertyProductKeyList = {
	"SuperLuck",
	"UltraLuck",
	"SecretHunter",
	"VIP",
	"GetPowerX2",
	"WinX2",
	"MaxSpeedX2",
	"CoinX2",
}

function IAPProperty:GetPropertyList(player)
	local result = {}
	for _, productKey in pairs(PropertyProductKeyList) do
		local iapProperty = IAPProperty:GetProperty(player, productKey)
		if iapProperty then
			table.insert(result, iapProperty)
		end
	end
	
	return result
end

function IAPProperty:GetProperty(player, productKey)
	local iapRequest = NetServer:RequireModule("IAP")
	local check = iapRequest:GetPurchaseCount(player, { 
		ProductKey = productKey
	})
	
	if not check or check == 0 then
		return nil
	else
		local propertyFunc = IAPProperty[productKey]
		if propertyFunc then
			local iapProperty = propertyFunc()
			iapProperty.ProductKey = productKey
			return iapProperty
		else
			return nil
		end	
	end
end

--------------------------------------------------------------------------------------

function IAPProperty:SuperLuck()
	return {
		["LuckyGetPetEpic1"] = 1,
	}
end

function IAPProperty:UltraLuck()
	return {
		["LuckyGetPetLegendary1"] = 9,
	}
end

function IAPProperty:SecretHunter()
	return {
		["LuckyGetPetSecret1"] = 99,
	}
end

function IAPProperty:VIP()
	return {
		["GetCoinFactor3"] = 0.2,
		--["GetWinFactor3"] = 0.2,
		["MaxSpeedFactor3"] = 1.0,
	}
end

function IAPProperty:GetPowerX2()
	return {
		["GetPowerFactor3"] = 1,
	}
end

function IAPProperty:WinX2()
	return {
		["GetWinsFactor3"] = 1,
	}
end

function IAPProperty:MaxSpeedX2()
	return {
		["MaxSpeedFactor3"] = 1,
	}
end

function IAPProperty:CoinX2()
	return {
		["GetCoinFactor3"] = 1,
	}
end


return IAPProperty
