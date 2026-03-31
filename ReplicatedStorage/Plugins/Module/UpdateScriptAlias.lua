local ScriptUtil = require(game.ReplicatedStorage.Plugins.Script.ScriptUtil)

local UpdateScriptAlias = {}

local ScriptCache = {}

local function GetClientAliasPath()
	local result = game.ReplicatedStorage:FindFirstChild("ScriptAlias")
	if not result then
		local folder = Instance.new("Folder")
		folder.Name = "ScriptAlias"
		folder.Parent = game.ReplicatedStorage
		result = folder
	end
	
	return result
end

local function GetServerAliasPath()
	local result = game.ServerScriptService:FindFirstChild("ScriptAlias")
	if not result then
		local folder = Instance.new("Folder")
		folder.Name = "ScriptAlias"
		folder.Parent = game.ServerScriptService
		result = folder
	end

	return result
end

local function CreateAliasFile(scriptFile, aliasPath)
	local scriptName = scriptFile.Name
	local fullPath = ScriptUtil:GetFullPath(scriptFile)
	local textLines = {
		"-- " .. fullPath,
		"-- " .. ScriptUtil:GetFullPath(aliasPath) .. "." .. scriptName,
		"local " .. scriptName .. " = require(" .. fullPath .. ")",
		"return " .. scriptName
	}
	
	local cache = ScriptCache[scriptName]
	if cache then
		table.insert(cache, fullPath)
		warn("[Update Script Alias] Same File Name : " .. scriptName)
		for index, file in ipairs(cache) do
			print(index, file)
		end
	else
		cache = {}
		table.insert(cache, fullPath)
		ScriptCache[scriptName] = cache
	end

	local aliasScript = aliasPath:FindFirstChild(scriptName)
	if aliasScript then
		aliasScript:Destroy()
	end
	
	aliasScript = Instance.new("ModuleScript")
	aliasScript.Name = scriptName
	aliasScript.Source = table.concat(textLines, "\n")
	aliasScript.Parent = aliasPath
end

local function CreateAliasByPath(targetPath , aliasPath)
	local scriptList = ScriptUtil:GetAllScriptsByPath(targetPath)
	for _, scriptFile in ipairs(scriptList) do
		CreateAliasFile(scriptFile, aliasPath)
	end
	
	print("[Update Script Alias] Success !",  ScriptUtil:GetFullPath(targetPath), #scriptList)
end

function UpdateScriptAlias:Execute(plugin)
	-- Client
	ScriptCache = {}
	local clientAliasPath = GetClientAliasPath()
	clientAliasPath:Destroy()
	clientAliasPath = GetClientAliasPath()
	for _, path in ipairs(ScriptUtil.ClientScrptPath) do
		CreateAliasByPath(path, clientAliasPath)
	end
	
	-- Server
	ScriptCache = {}
	local serverAliasPath = GetServerAliasPath()
	serverAliasPath:Destroy()
	serverAliasPath = GetServerAliasPath()
	for _, path in ipairs(ScriptUtil.ServerScriptPath) do
		CreateAliasByPath(path, serverAliasPath)
	end
end

return UpdateScriptAlias