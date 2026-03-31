local ExporterClient = require(game.ReplicatedStorage.Plugins.Module.ScriptExporterClient)
local SearchFunction = require(game.ReplicatedStorage.Plugins.Module.SearchFunction)
local UpdateScriptAlias = require(game.ReplicatedStorage.Plugins.Module.UpdateScriptAlias)

local ScriptExtension = {}

ScriptExtension.Icon = "📄"
ScriptExtension.Color = Color3.new(0.580392, 0.901961, 1)

function ScriptExtension:ScriptExporterClient(plugin)
	ExporterClient:Execute(plugin)
end

function ScriptExtension:SearchFunction(plugin)
	SearchFunction:Execute(plugin)
end

function ScriptExtension:UpdateScriptAlias()
	UpdateScriptAlias:Execute(plugin)
end

--function ScriptExtension:ScriptFixRequire()
--	ScriptFixRequire:Execute(plugin)
--end

return ScriptExtension
