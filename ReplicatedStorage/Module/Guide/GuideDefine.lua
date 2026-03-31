local GuideDefine = {}

GuideDefine.TargetMode = {
	Node = 0,
	Building = 1,
	Pos = 2,
}

GuideDefine.ArrowPrefab = "GuideArrow"
GuideDefine.ArrowHeight = 5

----------------------------------------------------------------------------------------
-- Demo

-- 引导配置模板
local Template = {
	["Step_Name"] = {
		-- 引导存储键值，与引导实现代码名字一致
		Key = "StepKey",
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
	}
}

----------------------------------------------------------------------------------------
-- Cofig

-- 引导挖掘
-- 引导建造
-- 引导攀爬
-- 引导抽宠物
-- 引导攀爬
-- 引导买背包

GuideDefine.GuideList = {
	-- Race
	[1] = {
		Key = "GuideStep_01_GoToRace",
		TipText = "Race Now! 🏁",
		TargetMode = GuideDefine.TargetMode.Building,
		TargetBuilding = "BuildingTrackUpEntrance",
	},
	-- Pet Loot
	[2] = {
		Key = "GuideStep_02_GoToPetLoot",
		TipText = "Get Your Pet! 🥚",
		TargetMode = GuideDefine.TargetMode.Building,
		TargetBuilding = "BuildingPetLoot1",
	},
	[3] = {
		Key = "GuideStep_03_PetLoot",
		TipText = "Hatch! ✨",
		TargetMode = GuideDefine.TargetMode.None,
		ShowUIList = {
			[1] = "UIPetLoot/MainFrame/LootFrame/Guide_PetLoot",
		},
	},
	[4] = {
		Key = "GuideStep_04_ClosePetLoot",
		TipText = "Awesome! ✅",
		TargetMode = GuideDefine.TargetMode.None,
		ShowUIList = {
			[1] = "UIPetLoot/MainFrame/LootFrame/Guide_Close",
		},
	},
	-- Pet Equip
	[5] = {
		Key = "GuideStep_05_OpenPetPack",
		TipText = "My Pets 🐾",
		TargetMode = GuideDefine.TargetMode.None,
		ShowUIList = {
			[1] = "UIMain/MainFrame/Right/Button_PetPack/GuideHand",
		},
	},
	[6] = {
		Key = "GuideStep_06_EquipPet",
		TipText = "Equip for more Coins! 💰",
		TargetMode = GuideDefine.TargetMode.None,
		ShowUIList = {
			[1] = "UIPetPack/MainFrame/StoreGui/InfoLab/Toggle_IsEquip_False/Button_Equip/GuideHand",
		},
	},
	[7] = {
		Key = "GuideStep_07_ClosePetPack",
		TipText = "Ready! 🌟",
		TargetMode = GuideDefine.TargetMode.None,
		ShowUIList = {
			[1] = "UIPetPack/MainFrame/StoreGui/Button_Close/GuideHand",
		},
	},
	-- Race
	[8] = {
		Key = "GuideStep_08_GoToRace",
		TipText = "Earn More Coins! 💸",
		TargetMode = GuideDefine.TargetMode.Building,
		TargetBuilding = "BuildingTrackUpEntrance",
	},
	-- Track Update
	[9] = {
		Key = "GuideStep_09_GoToTowerUpdate",
		TipText = "Unlock Longer Tracks 🛤️",
		TargetMode = GuideDefine.TargetMode.Building,
		TargetBuilding = "BuildingRailUpdate",
	},
	[10] = {
		Key = "GuideStep_10_UpdateTower",
		TipText = "Extend the Track 📈",
		TargetMode = GuideDefine.TargetMode.None,
		ShowUIList = {
			[1] = "UIRailUpdate/MainFrame/TrailList/Button_Buy/GuideHand",
		},
	},
	[11] = {
		Key = "GuideStep_11_CloseRailUpdate",
		TipText = "Ready!",
		TargetMode = GuideDefine.TargetMode.None,
		ShowUIList = {
			[1] =  "UIRailUpdate/MainFrame/TrailList/Button_Close/GuideHand",
		},
	},
	-- Race
	[12] = {
		Key = "GuideStep_12_GoToRace",
		TipText = "Go for a New Record! 🏆",
		TargetMode = GuideDefine.TargetMode.Building,
		TargetBuilding = "BuildingTrackUpEntrance",
	},
	-- Buy Tool
	[13] = {
		Key = "GuideStep_13_OpenToolStore",
		TipText = "Get a Faster Ride 🏎️",
		TargetMode = GuideDefine.TargetMode.Building,
		TargetBuilding = "BuildingToolStore",
	},
	[14] = {
		Key = "GuideStep_14_SelectTool",
		TipText = "Choose Your Car ⚡",
		TargetMode = GuideDefine.TargetMode.None,
		ShowUIList = {
			[1] = "UIToolStore/MainFrame/Guide_Select",
		},
	},
	[15] = {
		Key = "GuideStep_15_EquipTool",
		TipText = "Equip for Max Speed 🚀",
		TargetMode = GuideDefine.TargetMode.None,
		ShowUIList = {
			[1] =  "UIToolStore/MainFrame/StoreGui/InfoLab/Toggle_IsBuy_False/Info_CostCoin/Button_Buy/GuideHand",
		},
	},
	[16] = {
		Key = "GuideStep_16_CloseToolStore",
		TipText = "All Set! Let’s Race 🏁",
		TargetMode = GuideDefine.TargetMode.None,
		ShowUIList = {
			[1] = "UIToolStore/MainFrame/StoreGui/Button_Close/GuideHand",
		},
	},
}

return GuideDefine
