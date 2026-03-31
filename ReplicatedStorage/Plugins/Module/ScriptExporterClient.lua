local HttpService = game:GetService("HttpService")

local ScriptUtil = require(game.ReplicatedStorage.Plugins.Script.ScriptUtil)

local ScriptExporterClient = {}

-- 服务端地址
local SERVER_URL = "http://localhost:15566/Upload"

-- 判断是否是代码类对象
local function isCodeInstance(instance)
	return instance:IsA("Script") or instance:IsA("LocalScript") or instance:IsA("ModuleScript")
end

-- 获取对象路径（相对 game）
local function getFullPath(instance)
	local path = {}
	while instance and instance ~= game do
		table.insert(path, 1, instance.Name)
		instance = instance.Parent
	end
	return table.concat(path, "/")
end

-- 遍历获取所有脚本
local function getAllScriptList()
	local scriptList = {}
	for _, obj in ipairs(game:GetDescendants()) do
		if isCodeInstance(obj) then
			table.insert(scriptList, obj)
		end
	end
	return scriptList
end

-- 上传一个脚本到服务端
local function uploadScriptFile(scriptFile, index, count)
	local path = getFullPath(scriptFile)
	local scriptSource = scriptFile.Source
	if not scriptSource then
		print("❌ Empty File , Skip :" .. path)
		return
	end
	local success, result = pcall(function()
		local data = {
			Path = path,
			Script = scriptSource,
		}
		local json = HttpService:JSONEncode(data)
		HttpService:PostAsync(SERVER_URL, json, Enum.HttpContentType.ApplicationJson)
	end)

	if success then
		print("✅ Upload Success : " .. tostring(index) .. "/".. tostring(count), path)
		return true
	else
		warn("❌ Upload Fail : " .. path .. " -> " .. result)
		return false
	end
end

-- 上传所有脚本的主逻辑
local function uploadScriptList()
	local scripts = getAllScriptList()
	print("📦 Find Scripts:" .. tostring(#scripts))

	local count = #scripts
	for index, scriptFile in ipairs(scripts) do
		--local path = getFullPath(scriptFile)
		--print(path, scriptFile.Source)
		local success = uploadScriptFile(scriptFile, index, count)
		task.wait(0.17)
		if not success then
			break
		end
	end
end

function ScriptExporterClient:Execute()
	uploadScriptList()
end

return ScriptExporterClient