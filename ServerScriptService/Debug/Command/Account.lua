local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local Account = {}

Account.Icon = "🔑"
Account.Color = Color3.new(1, 0.666667, 0)

function Account:Log(player, param)
	local module = PlayerPrefs:GetModule(player, "Account")
	print(module)
end

function Account:Clear(player, param)
	local module = PlayerPrefs:GetModule(player, "Account")
	module.Coin = 0
	module.Wins = 0
	module.Power = 0
	
	EventManager:DispatchToClient(player, EventManager.Define.RefreshCoin, 0)
	EventManager:DispatchToClient(player, EventManager.Define.RefreshWins, 0)
	EventManager:DispatchToClient(player, EventManager.Define.RefreshPower, 0)
end

-- Coin

function Account:Coin10K(player, param)
	NetServer:RequireModule("Account"):AddCoin(player, { Value = 10000 })
end

function Account:Coin1M(player, param)
	NetServer:RequireModule("Account"):AddCoin(player, { Value = 1000000 })
end

function Account:Coin1B(player, param)
	NetServer:RequireModule("Account"):AddCoin(player, { Value = 1000000000 })
end

function Account:Coin1T(player, param)
	NetServer:RequireModule("Account"):AddCoin(player, { Value = 1000000000000 })
end

-- Wins

function Account:Wins10K(player, param)
	NetServer:RequireModule("Account"):AddWins(player, { Value = 10000 })
end

function Account:Wins1M(player, param)
	NetServer:RequireModule("Account"):AddWins(player, { Value = 1000000 })
end

function Account:Wins1B(player, param)
	NetServer:RequireModule("Account"):AddWins(player, { Value = 1000000000 })
end

function Account:Wins1T(player, param)
	NetServer:RequireModule("Account"):AddWins(player, { Value = 1000000000000 })
end

-- Power

function Account:Power100(player, param)
	NetServer:RequireModule("Account"):AddPower(player, { Value = 100 })
end

function Account:Power10K(player, param)
	NetServer:RequireModule("Account"):AddPower(player, { Value = 10000 })
end

function Account:Power1M(player, param)
	NetServer:RequireModule("Account"):AddPower(player, { Value = 1000000 })
end

function Account:Power100M(player, param)
	NetServer:RequireModule("Account"):AddPower(player, { Value = 100000000 })
end

return Account
