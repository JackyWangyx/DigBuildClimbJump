local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)

local GuideDefine = require(game.ReplicatedStorage.ScriptAlias.GuideDefine)

local GuideManager = {}

local SaveInfoList = nil
local RunGuideList = {}

function GuideManager:Init()
	NetClient:Request("Guide", "GetInfoList", function(infoList)
		SaveInfoList = infoList

		local guideStepFolder = script.Parent:FindFirstChild("Step")
		for index, guideConfig in ipairs(GuideDefine.GuideList) do
			local key = guideConfig.Key
			local guideInfo = infoList[key]

			-- 查找同名
			local guideScriptFile = nil
			if guideStepFolder then
				guideScriptFile = guideStepFolder:FindFirstChild(key)
			end

			if not guideScriptFile then
				-- 找不到，则直接用基础实现
				guideScriptFile = script.Parent.GuideStep
			end

			local guideScript = require(guideScriptFile)
			local guide = guideScript.new(key, guideConfig, guideInfo)
			table.insert(RunGuideList, guide)
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
	for _, guide in ipairs(RunGuideList) do
		if guide.Key == key then
			return guide
		end
	end

	return nil
end

function GuideManager:Refresh()
	for _, guide in ipairs(RunGuideList) do
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
		else
			warn("[Guide] ", key, "Failed!")
		end
	end)
end

return GuideManager
