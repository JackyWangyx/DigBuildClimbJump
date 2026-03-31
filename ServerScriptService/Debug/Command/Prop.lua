local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local Prop = {}

Prop.Icon = "💊"
Prop.Color = Color3.new(0.941176, 0.447059, 0.619608)

function Prop:Runtime(player, param)
	local info = NetServer:RequireModule("Prop"):GetRuntimeList(player)
	print(info)
end

function Prop:Package(player, param)
	local info = NetServer:RequireModule("Prop"):GetPackageList(player)
	print(info)
end

function Prop:Clear(player, param)
	PlayerPrefs:SetModule(player, "Prop", {})
	EventManager:DispatchToClient(player, EventManager.Define.RefreshProp)
end

return Prop
