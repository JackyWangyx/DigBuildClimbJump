local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local Define = require(game.ReplicatedStorage.Define)

local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local UIClickGameItem = require(script.Parent.UIClickGameItem)
local ClickGameEffect = require(script.Parent.ClickGameEffect)
local ClickGameDefine = require(script.Parent.ClickGameDefine)
local ClickFx = require(script.Parent.ClickFx)

local UIClickGame = {}

UIClickGame.EnableAnimation = false
UIClickGame.IsAutoClick = false

UIClickGame.UIRoot = nil
UIClickGame.SpawnParent = nil
UIClickGame.ClickItemList = {}

UIClickGame.Param = {
	SpawnIntervalMin = ClickGameDefine.SpawnIntervalMin,
	SpawnIntervalMax = ClickGameDefine.SpawnIntervalMax,
	MaxCount = ClickGameDefine.SpawnCountLimit,
	Duration = ClickGameDefine.LifeTimeDuration,
	ItemPrefab = Util:LoadPrefab("UIItem/UIClickGameItem"),
}

UIClickGame.OnItemSpawn = nil
UIClickGame.OnItemClick = nil
UIClickGame.OnItemUpdate = nil
UIClickGame.OnItemDeSpawn = nil

UIClickGame.Param = nil

local UpdateConnection = nil
local IsRunning = nil

-- UI

function UIClickGame:Init(root)
	UIClickGame.UIRoot = root
	UIClickGame.SpawnParent = root.MainFrame.SpawnFrame

	EventManager:Listen(EventManager.Define.RefreshAutoPlay, function(info)
		UIClickGame.IsAutoClick = info.IsAutoClick
	end)

	UpdateConnection = UpdatorManager:Heartbeat(function(deltaTime)
		UIClickGame:Update(deltaTime)
	end)
end

function UIClickGame:SetParam(param)
	UIClickGame.Param = {
		SpawnIntervalMin = param.SpawnIntervalMin,
		SpawnIntervalMax = param.SpawnIntervalMax,
		MaxCount = param.SpawnCountLimit,
		Duration = param.LifeTimeDuration,
		ItemPrefab = Util:LoadPrefab(param.ItemPrefab),
	}
end

function UIClickGame:OnShow(param)
end

function UIClickGame:OnHide(param)

end

function UIClickGame:Refresh(param)

end

-- Game

function UIClickGame:GameStart()
	if not UIClickGame.Param then
		UIClickGame:SetParam(ClickGameDefine.DefaultParam)
	end
	
	if not UIManager:ContainsCover("ClickGame") then
		UIManager:Cover("ClickGame")
	end

	IsRunning = true
	EventManager:Dispatch(EventManager.Define.ClickGameStart)
end

function UIClickGame:GameEnd()
	IsRunning = false
	UIClickGame:ClearItem()
	EventManager:Dispatch(EventManager.Define.ClickGameEnd)
end

-- Item

function UIClickGame:SpawnItem()
	local param = UIClickGame.Param
	local part = param.ItemPrefab:Clone()
	local initParam = {
		Parent = UIClickGame.SpawnParent,
		Part = part,
		Duration = param.Duration,
		Button = Util:GetChildByName(part, "Button_Click"),
		IsAutoClick = UIClickGame.IsAutoClick,
		OnSpawn = function(item)
			table.insert(UIClickGame.ClickItemList, item)
			if not UIClickGame.OnItemSpawn then return end
			UIClickGame.OnItemSpawn(item)
		end,
		OnClick = function(item)
			if not UIClickGame.OnItemClick then return end
			UIClickGame.OnItemClick(item)
		end,
		OnUpdate = function(item, deltaTime)
			if not UIClickGame.OnItemUpdate then return end
			UIClickGame.OnItemUpdate(item, deltaTime)
		end,
		OnDeSpawn = function(item)
			if UIClickGame.OnItemDeSpawn then 
				UIClickGame.OnItemDeSpawn(item)
			end

			Util:ListRemove(UIClickGame.ClickItemList, item)
		end,
	}

	local clickItem = UIClickGameItem.New(initParam)
	return clickItem
end

function UIClickGame:ClearItem()
	for _, clickItem in ipairs(UIClickGame.ClickItemList) do
		clickItem:DeSpawn()
	end

	UIClickGame.ClickItemList = {}
end

-- Update

local SpawnTimer = 0
local SpawnInterval = -1
local Random = Random.new()

function UIClickGame:Update(deltaTime)
	if not IsRunning then return end

	local currentTime = tick()
	local clickItemList = table.clone(UIClickGame.ClickItemList)
	for _, clickItem in ipairs(clickItemList) do
		clickItem:Update(deltaTime)
		if UIClickGame.IsAutoClick then
			if currentTime - clickItem.LastClickTime >= ClickGameDefine.AutoClickInterval then
				clickItem:AutoClick()
			end
		end
	end

	local param = UIClickGame.Param
	if SpawnInterval < 0 then
		SpawnInterval = Random:NextNumber(param.SpawnIntervalMin, param.SpawnIntervalMax)
	end

	SpawnTimer += deltaTime
	local itemCount = #UIClickGame.ClickItemList
	if SpawnTimer > SpawnInterval and itemCount < param.MaxCount then
		UIClickGame:SpawnItem()
		SpawnTimer = 0
		SpawnInterval = Random:NextNumber(param.SpawnIntervalMin, param.SpawnIntervalMax)
	end
end

return UIClickGame
