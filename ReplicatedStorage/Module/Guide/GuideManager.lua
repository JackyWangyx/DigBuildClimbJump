local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)

local GuideDefine = require(game.ReplicatedStorage.ScriptAlias.GuideDefine)

local GuideManager = {}

local SaveInfoList = nil
local GuideList = {}

function GuideManager:Init()
	NetClient:Request("Guide", "GetInfoList", function(infoList)
		SaveInfoList = infoList
		
		for index, guideConfig in ipairs(GuideDefine.GuideList) do
			local key = guideConfig.Key
			local guideInfo = infoList[key]
			local guideScriptFile = script.Parent.Step:FindFirstChild(key)
			local guideScript = require(guideScriptFile)
			local guide = guideScript.new(key, guideConfig, guideInfo)
			table.insert(GuideList, guide)
		end
		
		GuideManager:Refresh()
	end)
end

function GuideManager:GetConfig(key)
	for index, guideConfig in ipairs(GuideDefine.GuideList) do
		if guideConfig.Key == key then
			return guideConfig
		end
	end
	
	return nil
end

function GuideManager:GetGuide(key)
	for _, guide in ipairs(GuideList) do
		if guide.Key == key then
			return guide
		end
	end
	
	return nil
end

function GuideManager:Refresh()
	for _, guide in ipairs(GuideList) do
		if not guide.Info.IsComplete then
			guide:Enable()
			break
		end
	end
end

function GuideManager:Complete(key)
	local guide = GuideManager:GetGuide(key)
	if not guide then return end
	
	NetClient:Request("Guide", "Complete", { Key = key }, function(success)
		if success then
			guide:Disable()
			guide.Info.IsComplete = true
			GuideManager:Refresh()
		end
	end)
end

return GuideManager
