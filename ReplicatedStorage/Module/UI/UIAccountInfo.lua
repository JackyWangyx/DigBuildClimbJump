local TweenUtil   = require(game.ReplicatedStorage.ScriptAlias.TweenUtil)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local Util        = require(game.ReplicatedStorage.ScriptAlias.Util)
local NetClient   = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local BigNumber   = require(game.ReplicatedStorage.ScriptAlias.BigNumber)
local Define      = require(game.ReplicatedStorage.Define)

local UIAccountInfo = {}

-- 配置表：字段首字母大写
local TRACKED_RESOURCES = {
	Coin = {
		TargetName      = "UICoinTargetIcon",
		TipName         = "UIGetCoinTip",
		TextName        = "Text_Account_Coin",
		GetRemote       = {"Account", "GetCoin"},
		RefreshEvent    = EventManager.Define.RefreshCoin,
		GetEvent        = EventManager.Define.GetCoin,
		OnGetFunc       = "OnGetCoin",
		FlyToRandRotate = true,
	},
	Wins = {
		TargetName      = "UIWinsTargetIcon",
		TipName         = "UIGetWinsTip",
		TextName        = "Text_Account_Wins",
		GetRemote       = {"Account", "GetWins"},
		RefreshEvent    = EventManager.Define.RefreshWins,
		GetEvent        = EventManager.Define.GetWins,
		OnGetFunc       = "OnGetWins",
		FlyToRandRotate = false,
	},
	Power = {
		TargetName      = "UIPowerTarget",
		TipName         = "UIGetPowerTip",
		TextName        = "Text_Account_Power",
		GetRemote       = {"Account", "GetPower"},
		RefreshEvent    = EventManager.Define.RefreshPower,
		GetEvent        = EventManager.Define.GetPower,
		OnGetFunc       = "OnGetPower",
		FlyToRandRotate = false,
	},
}

-- 缓存的 UI 组件
local components = {}

function UIAccountInfo:Init(root)
	self.UIRoot = root

	for key, cfg in pairs(TRACKED_RESOURCES) do
		local target = Util:GetChildByName(root, cfg.TargetName, true)
		local tip    = Util:GetChildByName(root, cfg.TipName,    true)

		components[key] = {
			target = target,
			tip    = tip,
		}

		if tip then
			tip.Visible = false
			EventManager:Listen(cfg.GetEvent, function(value)
				self[cfg.OnGetFunc](self, value)
			end)
		end
	end
end

function UIAccountInfo:Handle(uiRoot, cacheChildList)
	if not cacheChildList then
		cacheChildList = uiRoot:GetDescendants()
	end

	for _, part in ipairs(cacheChildList) do
		for key, cfg in pairs(TRACKED_RESOURCES) do
			if part.Name == cfg.TextName and part:IsA("TextLabel") then
				-- 初次请求
				NetClient:Request(cfg.GetRemote[1], cfg.GetRemote[2], function(result)
					cfg.LastValue = result
					part.Text = BigNumber:Format(result)
				end)

				-- 监听刷新（带延迟）
				EventManager:Listen(cfg.RefreshEvent, function(value)
					if part and part.Parent then
						if cfg.LastValue ~= nil and cfg.LastValue > value then
								part.Text = BigNumber:Format(value)
						else
							task.delay(Define.Animation.RefreshAccountDelay, function()	
								part.Text = BigNumber:Format(value)
							end)
						end
					end
				end)

				break
			end
		end
	end
end

-- 统一的飞行动画处理
function UIAccountInfo:_FlyTip(key, value)
	local cfg = TRACKED_RESOURCES[key]
	local comp = components[key]
	if not (comp and comp.tip) then return end

	TweenUtil:UIFlyToTarget(comp.tip, comp.target, value, {
		RandRotate = cfg.FlyToRandRotate,
		ShowText   = false,
	})
end

function UIAccountInfo:OnGetCoin(value)
	self:_FlyTip("Coin", value)
end

function UIAccountInfo:OnGetWins(value)
	self:_FlyTip("Wins", value)
end

function UIAccountInfo:OnGetPower(value)
	self:_FlyTip("Power", value)
end

return UIAccountInfo