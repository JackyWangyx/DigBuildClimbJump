local ContentProvider = game:GetService("ContentProvider")

local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local BigNumber = require(game.ReplicatedStorage.ScriptAlias.BigNumber)
local ResourcesManager = require(game.ReplicatedStorage.ScriptAlias.ResourcesManager)
local UIEffect = require(game.ReplicatedStorage.ScriptAlias.UIEffect)
local UIAccountInfo = require(game.ReplicatedStorage.ScriptAlias.UIAccountInfo)

local Deifne = require(game.ReplicatedStorage.Define)

local UIPage = {}

function UIPage:Handle(uiRoot, uiScript, cacheChildList)
	if not cacheChildList then
		cacheChildList = uiRoot:GetDescendants()
	end
	
	task.spawn(function()
		UIInfo:HandleAllButton(uiRoot, uiScript, nil, cacheChildList)
	end)
	
	task.spawn(function()
		UIPage:HandleInfo(uiRoot, uiScript, cacheChildList)
	end)
end

function UIPage:HandleInfo(uiRoot, uiScriot, cacheChildList)
	if not cacheChildList then
		cacheChildList = uiRoot:GetDescendants()
	end

	-- Pre Load Images
	task.spawn(function()
		local images = {}
		for _, child in ipairs(cacheChildList) do
			if child:IsA("ImageLabel") or child:IsA("ImageButton") then
				table.insert(images, child)
			end
		end

		ContentProvider:PreloadAsync(images)
	end)

	UIAccountInfo:Handle(uiRoot, cacheChildList)

	-- Page Info
	for _, part in ipairs(cacheChildList) do
		-- Notify
		if Util:IsStrStartWith(part.Name, "Notify_") and part:IsA("ImageLabel") then
			local notifyName = string.match(part.Name, "_(.+)")
			local notifyScriptName = "Notify"..notifyName
			local notifyScriptFile = Util:GetChildByTypeAndName(game.ReplicatedStorage, "ModuleScript", notifyScriptName, true, ResourcesManager.ReplicatedStorageCache.Module)
			if notifyScriptFile then
				local notifyScript = require(notifyScriptFile)
				notifyScript:Handle(part)
				UIEffect:HandlePart(part:FindFirstChild("Notify"), UIEffect.EffectType.Shake)
			end	
		end
	end
end

return UIPage
