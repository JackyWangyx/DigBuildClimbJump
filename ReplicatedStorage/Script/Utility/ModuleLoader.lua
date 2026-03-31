local ModuleLoader = {}

local ModuleCache = {}

function ModuleLoader:CacheScript(moduleScript)
	ModuleCache[moduleScript.Name] = moduleScript
end

function ModuleLoader:Require(moduleName)
	local moduleScript = ModuleCache[moduleName]
	if not moduleScript then return nil end
	local module = require(moduleScript)
	return module
end

function ModuleLoader:ForEachScript(part, func)
	if not part then
		return
	else
		if part:IsA("ModuleScript") then
			func(part)
		else
			for _, child in ipairs(part:GetChildren()) do
				ModuleLoader:ForEachScript(child, func)
			end
		end
	end
end

-- Init
local ScriptRootFolder = game.ReplicatedStorage
ModuleLoader:ForEachScript(ScriptRootFolder, function(moduleScript)
	ModuleLoader:CacheScript(moduleScript)
end)


return ModuleLoader
