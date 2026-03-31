local ScriptUtil = {}

ScriptUtil.ClientScrptPath = {
	game.ReplicatedStorage.GamePlay,
	game.ReplicatedStorage.Module,
	game.ReplicatedStorage.Script,
}

ScriptUtil.ServerScriptPath = {
	game.ServerScriptService.GamePlay,
	game.ServerScriptService.Module,
	game.ServerScriptService.Net,
}

function ScriptUtil:GetFullPath(scriptFile)
	local path = {}
	local current = scriptFile
	while current ~= nil and current ~= game do
		table.insert(path, 1, current.Name)
		current = current.Parent
	end
	return "game." .. table.concat(path, ".")
end

function ScriptUtil:GetAllScriptsByPath(path) 
	local result = {}
	for _, obj in ipairs(path:GetDescendants()) do
		if obj:IsA("ModuleScript") then
			table.insert(result, obj)
		end
	end

	return result
end

return ScriptUtil
