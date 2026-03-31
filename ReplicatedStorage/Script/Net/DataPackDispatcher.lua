local RunService = game:GetService("RunService")

local NetDefine = require(script.Parent.NetDefine)

local DataPackDispatcher = {}

local IsClient = nil
local RequestCache = {
	Request = {},
	Broadcast = {},
}

function DataPackDispatcher:Init()
	IsClient = RunService:IsClient()
	DataPackDispatcher:CacheModule()
end

function DataPackDispatcher:RequireModule(moduleName)
	local module = RequestCache.Request[moduleName]
	if not module then
		module = RequestCache.Broadcast[moduleName]
	end
	
	return module
end

function DataPackDispatcher:CacheModule()
	local function cacheFromFolder(folder, targetCache)
		for _, child in ipairs(folder:GetChildren()) do
			if child:IsA("ModuleScript") then
				local requestScript = child
				local success, result = pcall(function()
					return require(requestScript)
				end)
				if success then
					local module = result
					targetCache[requestScript.Name] = module
					local initFunc = module["Init"]
					if initFunc and typeof(initFunc) == "function" then
						initFunc()
					end
				else
					warn("[Net] Failed to require module:", requestScript.Name, debug.traceback(result, 2))
				end
			else child:IsA("Folder")
				cacheFromFolder(child, targetCache)
			end
		end
	end

	if RunService:IsClient() then
		cacheFromFolder(game.ReplicatedStorage.Script.Net.Broadcast, RequestCache.Broadcast)
	else
		cacheFromFolder(game.ServerScriptService.Net.Request, RequestCache.Request)
	end
end

local function DispatchInternal(requestType, requestScript, player, module, action, param)
	local success, result = pcall(function()
		local actionFunc = requestScript[action]
		if requestType == NetDefine.RequestType.Request then
			local result = actionFunc(requestScript, player, param)
			return result
		else
			actionFunc(requestScript, player, param)
			return nil
		end
	end)

	if success then
		return result
	else
		warn("[Net] Dispatch Fail : ", requestType, module, action, param, debug.traceback(result, 2))
		return nil
	end
end

function DataPackDispatcher:Dispatch(requestType, player, module, action, param)
	if not player then return end
	local requestTable = RequestCache[requestType]
	if not requestTable then
		warn("[Net] Unknown request type: " .. tostring(requestType))
		return
	end

	local requestScript = requestTable[module]
	if not requestScript then
		warn("[Net] Request [" .. requestType .. "/" .. module .. "] not found in cache")
		return
	end

	local actionFunc = requestScript[action]
	if not actionFunc or type(actionFunc) ~= "function" then
		warn("[Net] Action ["..module.."/"..action.."] not found!")
		return
	end

	if IsClient then
		task.spawn(function()
			DispatchInternal(requestType, requestScript, player, module, action, param)
		end)
	else
		local result = DispatchInternal(requestType, requestScript, player, module, action, param)
		return result
	end
end

return DataPackDispatcher
