local RunService = game:GetService("RunService")

local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local SceneAreaManager = require(game.ReplicatedStorage.ScriptAlias.SceneAreaManager)

local ConfigManager = {}

local IsClient = RunService:IsClient()
local DataListCache = {}

-- How to use

--local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)

--local petTable = ConfigManager:GetTable("Pet")
--local row = ConfigManager:GetRow("Pet", 1)
--print(row)
--local value = ConfigManager:GetValue("Pet", 1, "Name")
--print(value)
--ConfigManager:Log(petTable)

function ConfigManager:GetDataSource()
	if SceneAreaManager.CurrentThemeKey then
		return SceneAreaManager.CurrentThemeKey 
	end
	
	return nil
end

function ConfigManager:FliterDataSource(configName, infoList)
	local resul = {}
	local currentDataSource = ConfigManager:GetDataSource()
	for index, info in ipairs(infoList) do
		local dataSource = info.DataSource
		if not dataSource then
			local data = ConfigManager:GetData(configName, info.ID)
			if data then
				dataSource = data.DataSource
			end	
		end
		
		if dataSource == nil or dataSource == currentDataSource then
			table.insert(resul, info)
		end
	end
	
	infoList = resul
	return resul
end

function ConfigManager:GetTableName(str)
	local len = #str
	if len >= 6 and str:sub(-6) == "Config" then
		return str
	else
		return str .. "Config"
	end
end

-- 解析 CSV 数据
function ConfigManager:DecodeRawData(csvData)
	if not csvData or #csvData == 0 then
		warn("Invalid or empty csv data")
		return nil
	end
	
	local dataList = {}
	local header = nil

	-- 按行分割数据
	for line in csvData:gmatch("[^\r\n]+") do
		-- 移除行两边的空白字符
		line = line:match("^%s*(.-)%s*$")
		-- 如果行为空，则跳过
		local rowCount = #line
		--print(rowCount, csvData)
		if rowCount > 0 then
			local row = {}
			-- 解析每一行的单元格数据（用逗号分隔）
			for cell in line:gmatch("([^,]+)") do
				table.insert(row, cell)
			end
			if not header then
				header = row
			else
				local data = {}
				for cellIndex, value in ipairs(row) do
					local key = header[cellIndex]
					-- ID 强制字符串，避免传输中被json数组化丢失非连续索引
					local num = tonumber(value)
					if num then
						data[key] = num
					else
						local lowerValue = string.lower(value)
						if lowerValue == "nil" or lowerValue == "nan" then
							data[key] = nil
						elseif lowerValue == "true" then
							data[key] = true
						elseif lowerValue == "false" then
							data[key] = false
						else
							data[key] = value
						end
					end
				end

				local id = tonumber(data["ID"])
				dataList[id] = data
			end
		end
	end

	return dataList
end

-- 从缓存获取表，没有则尝试加载
function ConfigManager:GetDataList(configName)
	if not configName then return nil end
	configName = ConfigManager:GetTableName(configName)
	local dataList = DataListCache[configName]
	if dataList then return dataList end
	
	if IsClient then
		-- Client
		local success, msg = pcall(function()
			-- 从服务端获取元数据（体积比lua table小），本地解析并缓存
			local rawData = NetClient:RequestWait("Config", "GetRawData", { ConfigName = configName})
			local result = ConfigManager:DecodeRawData(rawData)
			DataListCache[configName] = result
			return result
		end)
		
		if success then
			return msg
		else
			warn(msg)
			return nil
		end
	else
		-- Server
		local success, result = pcall(function()
			local rawData = ConfigManager:LoadRawData(configName)		
			dataList = ConfigManager:DecodeRawData(rawData)
			DataListCache[configName] = dataList
			return dataList
		end)
		
		if success then
			return result
		else
			warn("[Config] Load Fail : ", configName, debug.traceback(result, 2))
		end
	end
end

function ConfigManager:LoadRawData(configName)
	local configFile = Util:GetChildByTypeAndName(game.ServerStorage.Config, "ModuleScript", configName, true)
	if not configFile then
		local sceneManager = require(game.ReplicatedStorage.ScriptAlias.SceneManager)
		local levelFolder = game.ServerStorage.ConfigLevel:FindFirstChild(sceneManager.CurrentLevelName)
		if levelFolder then
			configFile = Util:GetChildByTypeAndName(levelFolder, "ModuleScript", configName, true)
		end	
	end
	
	local rawData = require(configFile).Data
	return rawData
end

function ConfigManager:GetCount(configName)
	local dataList = ConfigManager:GetDataList(configName)
	if not dataList then return 0 end
	local result = #dataList
	return result
end

-- 获取指定 ID 的数据
function ConfigManager:GetData(configName, id)
	if id == nil then return nil end
	local dataList = ConfigManager:GetDataList(configName)
	if not dataList then return nil end
 	if typeof(id) == "string" then
		id = tonumber(id)
	end
	local data = dataList[id]
	return data
end

-- 获取指定 ID 的数据
function ConfigManager:GetValue(configName, id, key)
	local data = ConfigManager:GetData(configName, id)
	if not data then
		return nil
	end

	local value = data[key]
	return value
end

-- 根据多对 key value 搜索数据
function ConfigManager:SearchData(configName, ...)
	local args = { ... }
	if #args % 2 ~= 0 then
		warn("[Config] Param Error : ", #args, configName, ...)
		return nil
	end

	local dataList = ConfigManager:GetDataList(configName)
	if not dataList then
		return nil
	end
	
	for _, data in ipairs(dataList) do
		local match = true
		for i = 1, #args, 2 do
			local key = args[i]
			local value = args[i + 1]
			if data[key] ~= value then
				match = false
				break
			end
		end
		
		if match then
			return data
		end
	end
	
	return nil
end

-- 根据多对 key value 搜索数据
function ConfigManager:SearchAllData(configName, ...)
	local args = { ... }
	if #args % 2 ~= 0 then
		warn("Parm Error")
		return
	end

	local dataList = ConfigManager:GetDataList(configName)
	if not dataList then
		return {}
	end

	local result = {}
	for _, data in ipairs(dataList) do
		local match = true
		for i = 1, #args, 2 do
			local key = args[i]
			local value = args[i + 1]
			if data[key] ~= value then
				match = false
				break
			end
		end

		if match then
			table.insert(result, data)
		end
	end

	return result
end

function ConfigManager:Log(dataList)
	if not dataList or #dataList == 0 then
		warn("Invalid or empty table data")
		return
	end
	for i, data in pairs(dataList) do
		local line = ""
		for key, value in pairs(data) do
			line = line..key .. ":" .. value.."\t "
		end
		print(line)
	end
end

return ConfigManager
