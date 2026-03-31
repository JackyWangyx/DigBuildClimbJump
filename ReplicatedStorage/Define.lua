local Define = {}

Define.Version = "2026.02.09.1"
Define.Project = "RollerCoaster"

-----------------------------------------------------------------------------------
-- 测试
Define.Test = {
	TestBuild = false,
	-- 测试签到首次登陆日期
	EnableSignLoginDate = false,
	LoginDate = {
		SignYear = 2025,
		SignMonth = 12, 
		SignDay = 1,
		SignHour = 0,
		SignMin = 0,
		SignSec = 0,
	},
	-- 测试签到当前日期
	EnableSignCurrentDate = false,
	CurrentDate = {
		SignYear = 2026,
		SignMonth = 1,
		SignDay = 16,
		SignHour = 0,
		SignMin = 0,
		SignSec = 0,
	},
	
	EnableSelfTrade = false, -- 允许和自己交易
	EnablePropertyLog = false, -- 打印分类属性列表
}

-----------------------------------------------------------------------------------
-- 任务 / 赛季 / 活动
Define.Quest = {
	SeasonKey = "Season_01",
	DailyQuestCount = 3,
	WeeklyQuestCount = 3,
	SeasonPassProperty = {
		GetPowerFactor3 = 0.5,
		LuckyGetPetLegendary1 = 0.5,
	},
	AdditionalPetEquip = 1,
}

Define.Activity = {
	Christmas2025 = {
		Name = "Christmas",
		EggPrefab = "Egg/Egg1225",
		StartDate = { year = 2025, month = 12, day = 15 },
		EndDate = { year = 2026, month = 1, day = 15 },
	},
}

-----------------------------------------------------------------------------------
-- 游戏参数
Define.Game = {
	-- Game
	GamePlaceID = 90478150465243,
	OfficalGroupID = 936613609,   ----online
	--OfficalGroupID = 557943437, ---devtest
	LevelCount = 1,
	TrackCount =  5,
	ViewSizeBefore = 3000,
	ViewSizeAfter = 3000,
	MineSize = 1,
	MaxDistance = 690000,
	MineCount = 690000,
	CountDown = 10,
	GameTime = 120,
	SpawnMineFxInterval = 0.1,
	RankBar = {
		[1] = {
			StartDis = 0,
			EndDis = 230000,
			Length = 230000,
		},
		[2] = {
			StartDis = 230001,
			EndDis = 460000,
			Length = 230000,
		},
		[3] = {
			StartDis = 460001,
			EndDis = 690000,
			Length = 230000,
		},
	},
	RankStr = {
		[1] = "1st",
		[2] = "2nd",
		[3] = "3rd",
		[4] = "4th",
		[5] = "5th",
		[6] = "6th",
		[7] = "7th",
		[8] = "8th",
		[9] = "9th",
		[10] = "10th",
		[11] = "11th",
		[12] = "12th",
		[13] = "13th",
		[14] = "14th",
		[15] = "15th",
		[16] = "16th",
		[17] = "17th",
		[18] = "18th",
		[19] = "19th",
		[20] = "20th"
	},
	-- Player
	WalkSpeed = 18,
	-- Trade
	TradeInviteTimeOut = 10,
	TradeCountDown = 5,
	TradeRequireRebirthLevel = 5,
	-- Buff
	BuffOnlineInterval = 60,
	BuffOnlineValue = 0.01,
	BuffInviteValue = 0.1,
	BuffPremiumValue = 0.2,
	-- Reward Package
	NewbiePackageID = 3,
	LikePackageID = 4,
}

Define.Animation = {
	RefreshAccountDelay = 1,
}

-----------------------------------------------------------------------------------
Define.DataSourceMode = {
	Default = 1,
	Theme = 2,
}

Define.Camera = {
	ZoomMinDistance = 2,
	ZoomMaxDistance = 100,
}

Define.Data = {
	GameRankSaveInterval = 300,
	PlayerAutoSaveInterval = 300,
}

Define.TradeState = {
	Prepare = 1,
	Trading = 2,
	Complete = 3,
}

Define.TradePlayerState = {
	Disable = 0,
	Idle = 1,
	Wait = 2,
	Busy = 3,
}

Define.IAPResult = {
	Complete = 1,
	Cancel = 2,
	Failed = 3,
}

-----------------------------------------------------------------------------------
Define.GamePhase = {
	Ready = 0,
	Start = 1,
	Gaming = 2,
	Finish = 3
}

Define.PlayerStatus = {
	Idle = 0,
	Training = 1,
	GameReady = 2,
	Gaming = 3
}

Define.Condition = {
	RebirethCount = "RebirthCount",
	TradeUnlock = "TradeUnlock",
}

-----------------------------------------------------------------------------------
-- 通知消息内容定义
Define.Message = {
	-- IAP
	IAPNotInGame = "Player is not in game!",
	IAPRequestNotFound = "Request not found!",
	IAPProcessNotFound = "Process function not found!",
	IAPPurchaseFailed = "Process failed!",

	-- General
	MaxLevel = "Reach the maximum level",
	CoinNotEnough = "Coin not enough!",
	WinsNotEnough = "Wins not enough!",
	PowerNotEnough = "Power not enough!",
	PowerFull = "Power Full!",
	PackageFull = "Pacakge Full!",
	Baught = "Purchase completed",
	Locked = "Locked",
	PreviousLocked = "Previous one not unlocked",
	
	-- Pet
	ConfirmDeletePet = "Delete selected pet?",
	
	-- Animal
	ConfirmDeleteAnimal = "Delete selected animal?",
	
	-- Training
	EnterTrainingMachine = "Enter Training Machine",

	-- Rebirth
	AutoRebirth = "Auto rebirth !",
	
	-- Scene Building
	BuyToolTip = "Buy Tool",
	BuyEquipmentTip = "Buy Equipment",
	BuyPartnerTip = "Buy Partner",
	BuyPetTip = "Buy Pet",
	BuyAnimalTip = "Buy Animal",
	EnterLevelFail = "Entry conditions not met",
	
	-- Prop
	PropNotExist = "Prop not exist",
	--PropTakingEffect = "Prop is taking effect",
	
	-- LuckyWheel
	LuckyWheelNotEnough = "Insufficient number of available",
	
	-- Trade
	TradeInviteSend = "Trade request sent！",
	TradeRejected = "Trade request was ignored！",
	TradeCanceld = "Trade Canceled",
	TradeClose = "Trade Closed",
	TradePackageFull = "Package Full ! Can't Confirm!",
	TradeComplete = "Trade Complete!",
	
	-- Redeem
	RedeemNotExist = "Code not exist!",
	RedeemFail = "Code already redeemed",
	
	-- Invite
	InvitePrompt = "⚡ +10% Speed Per Onlie Firend!", -- ⚡💰🪙
	
	-- Like
	NotInGroup = "👍 Like, favorite, and join our group to unlock!",
	
	-- Scene
	Teleporting = "Teleporting ! Please wait !",
	TeleportFail = "Transfer failed, please re-enter the game",
	
	-- Quest
	HasSeasonPass = "You have obtained the season pass.",
	
	-- Sign
	CanGetRewardTip = "Can Get!",
}

-----------------------------------------------------------------------------------
-- 事件定义
Define.Event = {
	-- System
	ShowUI = "ShowUI",
	HideUI = "HideUI",
	
	-- Game
	GameStartNewLoop = "GameStartNewLoop",
	GameEnter = "GameEnter",
	GameStart = "GameStart",
	GameLeave = "GameLeave",
	GameFinish = "GameFinish",
	RefreshAutoPlay = "RefreshAutoPlay",
	RefreshGameInfo = "RefreshGameInfo",
	RefreshOfficalGroup = "RefreshOfficalGroup",
	RefreshTheme = "RefreshTheme",
	RefreshTower = "RefreshTower",
	RefreshArea = "RefreshArea",
	
	-- Click Game
	ClickGameStart = "",
	ClickGameEnd = "",
	
	-- Player
	RefreshPlayerStatus = "RefreshPlayerStatus",
	
	-- Pet Loot
	PetLoot = "PetLoot",
	
	-- Training
	TrainingStart = "TrainingStart",
	TrainingEnd = "TrainingEnd",
	GetPower = "GetPower",
	
	-- Module
	RefreshPlayerProperty = "RefreshPlayerProperty",
	GetPet = "GetPet",
	GetAnimal = "GetAnimal",
	GetPartner = "GetPartner",
	RefreshPet = "RefreshPet",
	RefreshPetRenderer = "RefreshPetRenderer",
	PetLootStart = "PetLootStart",
	PetLootEnd = "PetLootEnd",
	
	RefreshTrail = "RefreshTrail",
	RefreshAnimal = "RefreshAnimal",
	RefreshPartner = "RefreshPartner",
	
	-- Tool
	GetTool = "GetTool",
	SelectTool = "SelectTool",
	RefreshTool = "RefreshTool",
	--EquipTool = "EquipTool",
	--UnEquipTool = "UnEquipTool",
	
	-- Equipment
	GetEquipment = "GetEquipment",
	SelectEquipment = "SelectEquipment",
	RefreshEquipment = "RefreshEquipment",
	
	-- Drive
	DriveStart = "DriveStart",
	DriveEnd = "DriveEnd",
	
	-- Info
	GetCoin = "GetCoin",
	GetWins = "GetWins",
	RefreshCoin = "RefreshCoin",
	RefreshWins = "RefreshWins",
	RefreshPower = "RefreshPower",
	RefreshRecord = "RefreshRecord",
	RefreshPremium = "RefreshPremium",
	RefreshPassPoint = "RefreshPassPoint",
	
	-- Rank
	RefreshRank = "RefreshRank",
	
	-- IAP
	RefreshGamePass = "RefreshGamePass",
	
	-- Prop
	RefreshProp = "RefreshProp",
	
	-- Rebirth
	RefreshRebirth = "RefreshRebirth",
	
	-- Sign
	RefreshSignDaily = "RefreshSignDaily",
	RefreshSignOnline = "RefreshSignOnline",
	
	-- Trade
	TradeInvite = "TradeInvite",
	TradeRejectInvite = "TradeRejectInvite",
	TradeAcceptInvite = "TradeAcceptInvite",
	TradeCancelInvite = "TradeCancelInvite",
	TradeClose = "TradeClose",
	TradeUpdate = "TradeUpdate",
	TradeComplete = "TradeComplete",
	TradePackageFull = "TradePackageFull",
	
	-- Buff
	RefreshBuffFriendOnline = "RefreshBuffFriendOnline",
	
	-- LuckyWheel
	RefreshLuckyWheel = "RefreshLuckyWheel",
	
	-- Teleport
	--TeleportFail = "TeleportFail",
	--TeleportSuccess = "TeleportSuccess",
	
	-- Build
	BuildStart = "BuildStart",
	BuildEnd = "BuildEnd",
	SwitchBuildPhase = "SwitchBuildPhase",
	RefreshBuildPartList = "RefreshBuildPartList",
	
	-- Quest Event
	RefreshQuest = "RefreshQuest",
	
	QuestGetCoin = "QuestGetCoin",
	QuestGetWins = "QuestGetWins",
	QuestGetPower = "QuestGetPower",
	QuestGetPassPoint = "QuestGetPassPoint",
	QuestRebirth = "QuestRebirth",
	QuestPetLoot = "QuestPetLoot",
	QuestGetPet = "QuestGetPet",
	QuestGetAnimal = "QuestGetAnimal",
	QuestGetPartner = "QuestGetPartner",
	QuestCompleteGame = "QuestCompleteGame",
	QuestOnlineTime = "QuestOnlineTime",
	QuestArriveEnd = "QuestArriveEnd",
	QuestGetTool = "QuestGetTool",
	QuestPetUpgrade = "QuestPetUpgrade",
	QuestUnlockLevel = "QuestUnlockLevel",
}

-----------------------------------------------------------------------------------
-- Analystics 事件定义
Define.Analytics = {
	PlayerLogin = "PlayerLogin",
	PlayGame = "PlayGame",
	PlayTraining = "PlayTraining",
	BuyTool = "BuyTool",
	BuyTrail = "BuyTrail",
	BuyPartner = "BuyPartner",
	BuyAnimal = "BuyAnimal",
	PetLoot = "PetLoot",
	Rebirth = "Rebirth",
	BuyProp = "BuyProp",
	UseProp = "UseProp",
	LuckyWheel = "LuckyWheel",
	CompleteQuestAchievement = "CompleteQuestAchievement",
	CompleteQuestWeekly = "CompleteQuestWeekly",
	CompleteQuestDaily = "CompleteQuestDaily",
	CompleteQuest = "CompleteQuest",
}

-----------------------------------------------------------------------------------
-- 游戏记录 Key 定义
Define.PlayerRecord = {
	MaxTrainingPower = "MaxTrainingPower",				-- 最大获取训练值
	TotalGetPower = "TotalGetPower",					-- 累积获取训练值
	TotalRebirth = "TotalRebirth",						-- 累积重生次数
	TotalGetCoin = "TotalGetCoin",						-- 累积获取金币
	TotalGetWins = "TotalGetWins",						-- 累积获取奖杯
	TotalClick = "TotalClick",							-- 累积点击次数
	TotalPassPoint = "TotalPassPoint",					-- 累积赛季通行证点数

	TotalPetLoot = "TotalPetLoot",
	TotalGetPet = "TotalGetPet",
	TotalCompleteGame = "TotalCompleteGame",
	TotalOnlineTime = "TotalOnlineTime",
	TotalArriveEnd = "TotalArriveEnd",
	TotalGetTool = "TotalGetTool",
	TotalGetAnimal = "TotalGetAnimal",
	TotalGetPartner = "TotalGetPartner",
	TotalPetUpgrade = "TotaltPetUpgrade",
	TotalUnlockLevel = "TotalUnlockLevel",
}

-----------------------------------------------------------------------------------
-- 排行榜
Define.RankList = {
	TotalGetPower = "TotalGetPower",
	TotalGetCoin = "TotalGetCoin",
	TotalGetWins = "TotalGetWins",
	TotalRebirth = "TotalRebirth",
	TotalClick = "TotalClick",
}

-----------------------------------------------------------------------------------
-- 玩家属性
Define.PlayerProperty = {
	SPEED = "Speed",
	ACCELERATION = "Acceleration",
	MAX_SPEED_FACTOR = "MaxSpeedFactor",
	
	BASE_POWER = "BasePower",
	POWER_LIMIT = "PowerLimit",

	GET_POWER_FACTOR = "GetPowerFactor",
	GET_COIN_FACTOR = "GetCoinFactor",
	GET_WINS_FACTOR = "GetWinsFactor",
	LUCKY_GET_PET_COMMON = "LuckyGetPetCommon",
	LUCKY_GET_PET_RARE = "LuckyGetPetRare",
	LUCKY_GET_PET_EPIC = "LuckyGetPetEpic",
	LUCKY_GET_PET_LEGENDARY = "LuckyGetPetLegendary",
	LUCKY_GET_PET_SECRET = "LuckyGetPetSecret",
	LUCKY_GET_PET_MYTHICAL = "LuckyGetPetMythical",
	LUCKY_PET_UPGRADE = "LuckyPetUpgrade",
}

-----------------------------------------------------------------------------------
-- 音乐 / 音效
Define.Sound = {
	PlaySfxInterval = 0.1,
	BGM = "BackgroundMusic",
	Celebrate = "Celebrate",
	Loot = "OpenEgg",
	MineBreak1 = "RockDestory01",
	MineBreak2 = "RockDestory02",
	UIClick = "UIClick",
	CountDown = "CountDown",
	TrainingCar = "DigVehicle",
	TrainingTool = "DigDefault",
	
	BuildTower = "Building",
	Dig = "DigDefault",
}

return Define
