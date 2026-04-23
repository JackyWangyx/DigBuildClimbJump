local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local SceneAreaManager = require(game.ReplicatedStorage.ScriptAlias.SceneAreaManager)

local ClimbTowerDefine = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerDefine)

local GuideDefine = {}

GuideDefine.TargetMode = {
	None = 0,
	Building = 1,
	Pos = 2,
	Custom = 3,
}

GuideDefine.TriggerMode = {
	Custom = 0,
	Event = 1,
}

GuideDefine.ArrowPrefab = "GuideArrow"
GuideDefine.ArrowHeight = 1

----------------------------------------------------------------------------------------
-- Demo

-- 引导配置模板
local Template = {
	["Step_Name"] = {
		-- 引导存储键值，与引导实现代码名字一致
		Key = "StepKey",
		-- 触发模式
		TriggerMode = GuideDefine.TriggerMode.Event,
		-- 触发事件
		TriggerEvent = EventManager.Define.GameFinish,
		-- 事件过滤参数
		TriggerEventParam = nil,
		-- 引导提示文本
		TipText = "Step_TipText",
		-- 引导进行中显示的组件
		ShowPartList = {
			--[1] = "LevelRoot/Game/....",
		},
		-- 引导进行中显示的UI
		ShowUIList = {
			--[1] = "Page/UIMain/...",
		},
		-- 引导指向模式
		TargetMode = GuideDefine.TargetMode.Building,
		-- 引导指向的建筑
		TargetBuilding = "BuildingTool",
		-- 引导指向的坐标
		TargetPos = Vector3.zero,
		-- 自定义目标位置获取函数
		TargetCustomPosFunc = nil,
	}
}

----------------------------------------------------------------------------------------
-- Cofig

GuideDefine.GuideList = {
	-- Dig01
	[1] = {
		Key = "GuideStep_01",
		TipText = "⛏️ Dig 5 times 0/5",
		TriggerMode = GuideDefine.TriggerMode.Event,
		TriggerEvent = ClimbTowerDefine.Event.Dig,
		TargetMode = GuideDefine.TargetMode.Building,
		TargetBuilding = "BuildingDigArea",
	},
	-- Dig02
	[2] = {
		Key = "GuideStep_02",
		TipText = "⛏️ Dig 5 times 1/5",
		TriggerMode = GuideDefine.TriggerMode.Event,
		TriggerEvent = ClimbTowerDefine.Event.Dig,
		TargetMode = GuideDefine.TargetMode.Building,
		TargetBuilding = "BuildingDigArea",
	},
	-- Dig03
	[3] = {
		Key = "GuideStep_03",
		TipText = "⛏️ Dig 5 times 2/5",
		TriggerMode = GuideDefine.TriggerMode.Event,
		TriggerEvent = ClimbTowerDefine.Event.Dig,
		TargetMode = GuideDefine.TargetMode.Building,
		TargetBuilding = "BuildingDigArea",
	},
	-- Dig04
	[4] = {
		Key = "GuideStep_04",
		TipText = "⛏️ Dig 5 times 3/5",
		TriggerMode = GuideDefine.TriggerMode.Event,
		TriggerEvent = ClimbTowerDefine.Event.Dig,
		TargetMode = GuideDefine.TargetMode.Building,
		TargetBuilding = "BuildingDigArea",
	},
	-- Dig05
	[5] = {
		Key = "GuideStep_05",
		TipText = "⛏️ Dig 5 times 4/5",
		TriggerMode = GuideDefine.TriggerMode.Event,
		TriggerEvent = ClimbTowerDefine.Event.Dig,
		TargetMode = GuideDefine.TargetMode.Building,
		TargetBuilding = "BuildingDigArea",
	},
	-- Build
	[6] = {
		Key = "GuideStep_06",
		TipText = "🧱 Build your tower!",
		TriggerMode = GuideDefine.TriggerMode.Event,
		TriggerEvent = ClimbTowerDefine.Event.BuildTower,
		TargetMode = GuideDefine.TargetMode.Building,
		TargetBuilding = "BuildingTowerUpdate",
		ShowUIList = {
			[1] = "UIMain/MainFrame/DigFrame/Button_GoToTower/Guide_Select",
		},
	},
	-- Game
	[7] = {
		Key = "GuideStep_07",
		TipText = "🧗 Climb up,then jump!",
		TriggerMode = GuideDefine.TriggerMode.Event,
		TriggerEvent = ClimbTowerDefine.Event.Exit,
		TargetMode = GuideDefine.TargetMode.Custom,
		TargetCustomPosFunc = function()
			local areaInfo = SceneAreaManager.AreaInfoList[SceneAreaManager.CurrentAreaIndex]
			local towerPos = areaInfo.Area.Game.TowerPos
			return towerPos.Position
		end,
	},
	-- Pet Loot
	[8] = {
		Key = "GuideStep_08",
		TipText = "🥚 Get Your Pet!",
		TriggerMode = GuideDefine.TriggerMode.Event,
		TriggerEvent = EventManager.Define.ShowUI,
		TriggerEventParam = "UIPetLoot",
		TargetMode = GuideDefine.TargetMode.Building,
		TargetBuilding = "BuildingPetLoot1",
	},
	[9] = {
		Key = "GuideStep_09",
		TipText = "✨ Hatch!",
		TriggerMode = GuideDefine.TriggerMode.Event,
		TriggerEvent = EventManager.Define.PetLoot,
		TargetMode = GuideDefine.TargetMode.None,
		ShowUIList = {
			[1] = "UIPetLoot/MainFrame/LootFrame/Guide_PetLoot",
		},
	},
	[10] = {
		Key = "GuideStep_10",
		TipText = "✅ Awesome!",
		TriggerMode = GuideDefine.TriggerMode.Event,
		TriggerEvent = EventManager.Define.HideUI,
		TriggerEventParam = "UIPetLoot",
		TargetMode = GuideDefine.TargetMode.None,
		ShowUIList = {
			[1] = "UIPetLoot/MainFrame/LootFrame/Guide_Close",
		},
	},

	--[[
	-- Pet Equip
	[12] = {
		Key = "GuideStep_07_OpenPetPack",
		TipText = "My Pets 🐾",
		TriggerEvent = EventManager.Define.ShowUI,
		TriggerEventParam = "UIPetPack",
		TargetMode = GuideDefine.TargetMode.None,
		ShowUIList = {
			[1] = "UIMain/MainFrame/Right/Button_PetPack/GuideHand",
		},
	},
	[13] = {
		Key = "GuideStep_08_EquipPet",
		TipText = "Equip for more Coins! 💰",
		TriggerMode = GuideDefine.TriggerMode.Event,
		TriggerEvent = EventManager.Define.RefreshPet,
		TargetMode = GuideDefine.TargetMode.None,
		ShowUIList = {
			[1] = "UIPetPack/MainFrame/StoreGui/InfoLab/Toggle_IsEquip_False/Button_Equip/GuideHand",
		},
	},
	[9] = {
		Key = "GuideStep_09_ClosePetPack",
		TipText = "Ready! 🌟",
		TriggerEvent = EventManager.Define.HideUI,
		TriggerEventParam = "UIPetPack",
		TargetMode = GuideDefine.TargetMode.None,
		ShowUIList = {
			[1] = "UIPetPack/MainFrame/StoreGui/Button_Close/GuideHand",
		},
	},
	-- Game
	[10] = {
		Key = "GuideStep_10_GoToClimb",
		TipText = "Go to Climb",
		TriggerMode = GuideDefine.TriggerMode.Event,
		TriggerEvent = ClimbTowerDefine.Event.Exit,
		TargetMode = GuideDefine.TargetMode.Custom,
		TargetCustomPosFunc = function()
			local areaInfo = SceneAreaManager.AreaInfoList[SceneAreaManager.CurrentAreaIndex]
			local towerPos = areaInfo.Area.Game.TowerPos
			return towerPos.Position
		end
	},
	]]

	-- Buy Tool
	[11] = {
		Key = "GuideStep_11",
		TipText = "Get a Backpack!",
		TriggerMode = GuideDefine.TriggerMode.Event,
		TriggerEvent = EventManager.Define.ShowUI,
		TriggerEventParam = "UIToolStore",
		TargetMode = GuideDefine.TargetMode.Building,
		TargetBuilding = "BuildingToolStore",
	},
	[12] = {
		Key = "GuideStep_12",
		TipText = "⚡ Choose this!",
		TriggerMode = GuideDefine.TriggerMode.Event,
		TriggerEvent = EventManager.Define.SelectTool,
		TargetMode = GuideDefine.TargetMode.None,
		ShowUIList = {
			[1] = "UIToolStore/MainFrame/Guide_Select",
		},
	},
	[13] = {
		Key = "GuideStep_13",
		TipText = "🚀 Equip for Faster Speed",
		TriggerMode = GuideDefine.TriggerMode.Event,
		TriggerEvent = EventManager.Define.RefreshTool,
		TargetMode = GuideDefine.TargetMode.None,
		ShowUIList = {
			[1] =  "UIToolStore/MainFrame/StoreGui/InfoLab/Toggle_IsBuy_False/Info_CostCoin/Button_Buy/GuideHand",
		},
	},
	[14] = {
		Key = "GuideStep_14",
		TipText = "All Set! Let’s Race 🏁",
		TriggerMode = GuideDefine.TriggerMode.Event,
		TriggerEvent = EventManager.Define.HideUI,
		TriggerEventParam = "UIToolStore",
		TargetMode = GuideDefine.TargetMode.None,
		ShowUIList = {
			[1] = "UIToolStore/MainFrame/StoreGui/Button_Close/Guide_Select",
		},
	},
}

return GuideDefine
