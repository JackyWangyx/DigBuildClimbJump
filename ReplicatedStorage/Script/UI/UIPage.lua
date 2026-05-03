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
local UIIndexManager = require(game.ReplicatedStorage.ScriptAlias.UIIndexManager)

local Deifne = require(game.ReplicatedStorage.Define)

local UIPage = {}

local NotifyScriptCache = {}

function UIPage:Handle(uiRoot, uiScript)
	local images = {}
	local notifyList = {}

	UIIndexManager:ForeachInNode(uiRoot, function(child)
		local className = child.ClassName
		if className == "ImageLabel" or className == "ImageButton" then
			images[#images + 1] = child
		end

		if className == "ImageLabel" and string.sub(child.Name, 1, 7) == "Notify_" then
			notifyList[#notifyList + 1] = child
		end
	end)

	-- UI按钮处理（延迟一帧，避免卡顿）
	task.defer(function()
		UIInfo:HandleAllButton(uiRoot, uiScript, nil, false)
	end)

	-- 账号信息（同步执行，通常不重）
	UIAccountInfo:Handle(uiRoot)

	-- 图片预加载（分批）
	if #images > 0 then
		task.spawn(function()
			local BATCH_SIZE = 50
			for i = 1, #images, BATCH_SIZE do
				local batch = {}
				for j = i, math.min(i + BATCH_SIZE - 1, #images) do
					batch[#batch + 1] = images[j]
				end
				ContentProvider:PreloadAsync(batch)
				task.wait() -- 防止卡帧
			end
		end)
	end

	-- Notify处理
	for i = 1, #notifyList do
		local part = notifyList[i]

		local notifyName = string.match(part.Name, "_(.+)")
		if notifyName then
			local scriptName = "Notify" .. notifyName

			local notifyScript = NotifyScriptCache[scriptName]
			if not notifyScript then
				local module = ResourcesManager:GetScript(scriptName)
				if module then
					notifyScript = require(module)
					NotifyScriptCache[scriptName] = notifyScript
				end
			end

			if notifyScript then
				notifyScript:Handle(part)

				local notifyChild = part:FindFirstChild("Notify")
				if notifyChild then
					UIEffect:HandlePart(notifyChild, UIEffect.EffectType.Shake)
				end
			end
		end
	end
end

return UIPage