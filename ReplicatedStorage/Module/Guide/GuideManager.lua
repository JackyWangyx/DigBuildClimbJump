local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)

local GuideDefine = require(game.ReplicatedStorage.ScriptAlias.GuideDefine)

local GuideManager = {}

local SaveInfoList = nil
local RunGuideList = {}

function GuideManager:Init()
	NetClient:Request("Guide", "GetInfoList", function(infoList)
		SaveInfoList = infoList

		local guideStepFolder = script.Parent:FindFirstChild("Step")
		for index, config in ipairs(GuideDefine.GuideList) do
			local key = config.Key
			local info = infoList[key]

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
			local guide = guideScript.new(key, config, info)
			table.insert(RunGuideList, guide)
		end

		GuideManager:Refresh()
	end)
end

function GuideManager:GetConfig(key)
	for index, config in ipairs(GuideDefine.GuideList) do
		if config.Key == key then
			return config
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
	local find = false
	for _, guide in ipairs(RunGuideList) do
		if not guide.Info.IsComplete then
			guide:Enable()
			find = true
			break
		end
	end
	
	if not find then
		local page = UIManager:GetPage("UIMain")
		local root = page.MainFrame
		local uiGuide = Util:GetChildByName(root, "GuideFrame", true)
		if uiGuide then
			uiGuide.Visible = false
		end
	end
end

function GuideManager:Complete(key, onDone)
	local guide = GuideManager:GetGuide(key)
	if not guide then return end

	NetClient:Request("Guide", "Complete", { Key = key }, function(success)
		if success then
			guide:Disable()
			guide.Info.IsComplete = true
			GuideManager:Refresh()
			onDone(true)
		else
			warn("[Guide] ", key, "Failed!")
			onDone(false)
		end
	end)
end

return GuideManager
