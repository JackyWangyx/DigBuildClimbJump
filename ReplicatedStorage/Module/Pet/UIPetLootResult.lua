local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local AttributeUtil = require(game.ReplicatedStorage.ScriptAlias.AttributeUtil)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local UIListSelect = require(game.ReplicatedStorage.ScriptAlias.UIListSelect)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local UIConfirm = require(game.ReplicatedStorage.ScriptAlias.UIConfirm)
local PetUtil = require(game.ReplicatedStorage.ScriptAlias.PetUtil)
local TweenUtil = require(game.ReplicatedStorage.ScriptAlias.TweenUtil)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local SoundManager = require(game.ReplicatedStorage.ScriptAlias.SoundManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)

local UIPetLootResult = {}

UIPetLootResult.UIRoot = nil
UIPetLootResult.ManualFrame = nil
UIPetLootResult.AutoFrame = nil

UIPetLootResult.Param = nil

UIPetLootResult.ItemList = nil

UIPetLootResult.ModelViewDistance = -2
UIPetLootResult.SpawnEggDuration = 3
UIPetLootResult.SpawnPetDuration = 1.2
UIPetLootResult.OpenAutoWaitDuration = 1

UIPetLootResult.OpenEggDuration1 = 3
UIPetLootResult.CacheObjectList = {}

function UIPetLootResult:Init(root)
	UIPetLootResult.UIRoot = root

	local childList = UIPetLootResult.UIRoot:GetDescendants()
	UIPetLootResult.ManualFrame = Util:GetChildByName(UIPetLootResult.UIRoot, "ManualFrame", childList)
	UIPetLootResult.AutoFrame = Util:GetChildByName(UIPetLootResult.UIRoot, "AutoFrame", childList)
	
	EventManager:Listen("OpenPetLoot", function(param)
		UIManager:ShowAndHideOther("PetLootResult", param)
	end)
end

function UIPetLootResult:CheckExclusive()
	return true
end

function UIPetLootResult:OnShow(param)
	UIPetLootResult.Param = param
	EventManager:Dispatch(EventManager.Define.PetLootStart)
	UIPetLootResult:Open()
	
	PlayerManager:DisableMove(game.Players.LocalPlayer)
end

function UIPetLootResult:OnHide()
	UIPetLootResult:ClearCache()
	EventManager:Dispatch(EventManager.Define.PetLootEnd)
	
	PlayerManager:EnableMove(game.Players.LocalPlayer)
end

function UIPetLootResult:ClearCache()
	for _, object in pairs(UIPetLootResult.CacheObjectList) do
		object:Destroy()
	end
	UIPetLootResult.CacheObjectList = {}
end

UIPetLootResult.OpenTaskRunning = false

function UIPetLootResult:Open()
	local skipOpen = false
	
	EventManager:Dispatch(EventManager.Define.PetLoot)
	
	IAPClient:CheckHasGamePass("FastHatch", function(result)
		skipOpen = result
	end)
	
	task.wait()
	local param = UIPetLootResult.Param
	local lootKey = param.LootKey
	local count = param.LootCount
	local deleteIDList = param.DeleteIDList
	local openAuto = param.OpenAuto
	local times = param.Times
	local isRobuxLoot = param.IsRobuxLoot
	local isRewardLoot = param.IsRewardLoot

	UIPetLootResult.OpenTaskRunning = true
	
	local timesCounter = 0
	local openCounter = 0
	
	UIManager.Enable = false
	while true do
		UIPetLootResult:ClearCache()
		local isOpen = false
		local isOpenFail = false
		
		UIPetLootResult.AutoFrame.Visible = openAuto and not isRobuxLoot and not isRewardLoot
		UIPetLootResult.ManualFrame.Visible = false
			
		PetUtil:OpenLoot(lootKey, deleteIDList, count, function(result)
			if result.Success then
				UIPetLootResult:OpenOnce(result.PetList, skipOpen, function()
					isOpen = true
					openCounter = openCounter + 1
				end)
			else
				isOpen = true
				isOpenFail = true
			end
		end)

		-- 等待开奖结果
		while not isOpen do
			task.wait(0.01)
		end
		
		timesCounter += 1
		local timesOver = times >= 1 and timesCounter >= times

		if isOpenFail then
			UIPetLootResult.ItemList = UIList:LoadWithInfo(UIPetLootResult.UIRoot, "UIPetLootResultItem", {})
		end
		
		--print("Time:", timesCounter, times, "Auto:",openAuto, "Reward:", isRewardLoot)
		local finish = isOpenFail or timesOver or not UIPetLootResult.OpenTaskRunning
		if finish then
			UIPetLootResult.AutoFrame.Visible = false
			UIPetLootResult.ManualFrame.Visible = true
			break
		else
			if openAuto then
				local showAuto = not isRewardLoot and not isRobuxLoot
				UIPetLootResult.AutoFrame.Visible = showAuto
				UIPetLootResult.ManualFrame.Visible = false
			else
				UIPetLootResult.AutoFrame.Visible = false
				UIPetLootResult.ManualFrame.Visible = true
			end
		end

		task.wait(UIPetLootResult.OpenAutoWaitDuration)
	end
	
	UIManager.Enable = true
end

function UIPetLootResult:OpenOnce(petDataList, skipOpen, onDone)
	UIPetLootResult.ItemList = UIList:LoadWithInfo(UIPetLootResult.UIRoot, "UIPetLootResultItem", petDataList)	
	local count = #petDataList
	for _, item in ipairs(UIPetLootResult.ItemList) do
		item.PetInfo.Visible = false
	end

	if not skipOpen then
		for i = 1, count do
			local item = UIPetLootResult.ItemList[i]
			task.spawn(function()
				UIPetLootResult:OpenStep1Egg(item, petDataList[i])
			end)
		end
		task.wait(UIPetLootResult.SpawnEggDuration)
	end

	for i = 1, count do
		local item = UIPetLootResult.ItemList[i]
		local petInfoPart = item.PetInfo
		task.spawn(function()
			local petData = petDataList[i]
			UIPetLootResult:OpenStep2Pet(item, petData)
			UIInfo:SetInfo(petInfoPart, petData)
		end)
	end
	task.wait(UIPetLootResult.SpawnPetDuration)

	for _, item in ipairs(UIPetLootResult.ItemList) do
		item.PetInfo.Visible = true
	end

	onDone()
end

-- 开蛋
function UIPetLootResult:OpenStep1Egg(item, petData)
	local eggPrefab = Util:LoadPrefab(UIPetLootResult.Param.EggPrefab)
	local egg = eggPrefab:Clone()
	egg.Parent = item.Viewport.ModelPos

	SoundManager:PlaySFX(SoundManager.Define.Loot)

	-- 加 Weld，保证所有子部件跟着 PrimaryPart 动
	for _, part in ipairs(egg:GetDescendants()) do
		if part:IsA("BasePart") and part ~= egg.PrimaryPart then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = egg.PrimaryPart
			weld.Part1 = part
			weld.Parent = egg.PrimaryPart
		end
	end

	Util:SetPosition(egg, Vector3.new(0, 0, UIPetLootResult.ModelViewDistance))
	Util:SetRotation(egg, Vector3.new(0, -180, 0))

	TweenUtil:ModelZoomIn(egg, 0.25)
	task.wait(0.25)

	-- 🛑 播抖动动画，内部自己耗时3秒
	TweenUtil:EggShakeModel(egg)

	-- 🛑 抖动完后，直接销毁蛋
	egg:Destroy()
end


-- 开宠物
function UIPetLootResult:OpenStep2Pet(item, petData)
	UIPetLootResult:SpawnOpenFx()

	local petPrefab = Util:LoadPrefab(petData.Prefab)
	if petPrefab then
		local pet = petPrefab:Clone()
		table.insert(UIPetLootResult.CacheObjectList, pet)

		pet.Parent = item.Viewport.ModelPos
		Util:SetPosition(pet, Vector3.new(0, 0, UIPetLootResult.ModelViewDistance))
		Util:SetRotation(pet, Vector3.new(0, -180, 0))
		TweenUtil:ModelZoomIn(pet, 1)
		task.wait(0.1)
		TweenUtil:ModelRotateY(pet, -180, 180, 1)
	else
		warn("[PetLoot] Prefab not found!", petData.ID)
	end
end

function UIPetLootResult:SpawnOpenFx()
	local fxPrefab = Util:LoadPrefab("Fx/UI/FxConfetti")
	Util:SpawnScreenFx(fxPrefab)
end

function UIPetLootResult:Button_Continue()
	--UIManager:Hide("UIPetLootResult")
	if UIPetLootResult.Param.IsRewardLoot then
		UIManager:Hide("UIPetLootResult")	
	else
		local param = table.clone(UIPetLootResult.Param)
		UIManager:ShowAndHideOther("UIPetLoot", param)
	end
end

function UIPetLootResult:Button_Stop()
	UIPetLootResult.OpenTaskRunning = false
	UIPetLootResult.AutoFrame.Visible = false	
	UIPetLootResult.ManualFrame.Visible = true
end

return UIPetLootResult