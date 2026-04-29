local ClimbTowerDefine = {}

ClimbTowerDefine.TrackAngle = 30

ClimbTowerDefine.ClickGameUpParam = {
	SpawnIntervalMin = 3,
	SpawnIntervalMax = 5,
	SpawnCountLimit = 5,
	LifeTimeDuration = 2,
	ItemPrefab = "UIItem/UIClickGameItem",
}

ClimbTowerDefine.ClickGameDownParam = {
	SpawnIntervalMin = 3,
	SpawnIntervalMax = 5,
	SpawnCountLimit = 5,
	LifeTimeDuration = 2,
	ItemPrefab = "UIItem/UIClickGameItem",
}

ClimbTowerDefine.Game = {
	-- 伙伴位置
	PartnerIdleOffset = Vector3.new(5, 0, 3),
	PartnerGameOffset = Vector3.new(3, 0, 0.1),
	-- 塔的初始高度
	TowerHeightDefault = -1,
	--TowerUpgradeDuration = 5,
	TowerUpgradeSpeed = 500,
	--TowerUpgradeFx = "Fx/Fx_PlayerDrop",
	AutoClimbStopTopOffset = -1,
	-- 挖掘区域生成参数
	DigAreaPos = Vector3.new(0, -515, 0),
	DigAreaSize = Vector3.new(256, 1024, 256),
	DigAreaResetTime = 600,
	DigFx = "Fx/Fx_Dig",
	--DigAreaRadius = 80,
	--DigAreaHeight = 10000,
	-- 挖掘区域重置时间
	DigAreaAutoResetTime = 120,
	-- 地面高度偏移量
	GroundHeightOffset = 1,
	-- 检查落地高度阈值
	LandedCheckHeight = 12,
	-- 攀爬最大速度
	MaxClimbSpeed = 1500,
	-- 坠落动画
	PlayerFallAnimation = "rbxassetid://507767968",
	-- 落地特效延迟
	DropEffectDelay = 0.35,
	--DropFx = "Fx/Fx_PlayerDrop", 
	-- 落地相机震动参数
	DropCameraShakeParam = {
		Poweer = Vector3.new(1, 0.5, 1),
		Duration = 1,
		Count = 6
	},
	-- 点击游戏获取金币系数
	ClickGameGetCoinFactor = 0.5,
}

ClimbTowerDefine.GamePhase = {
	Idle = 1,
	Up = 2,
	ArriveEnd = 3,
	Down = 4,
	Busy = 10000,
}

ClimbTowerDefine.Event = {
	ResetToDig = "ResetToDig",
	ResetToTower = "ResetToTower",
	
	RefreshTower = "RefreshTower",
	BuildTower = "BuildTower",
	BuildTowerAnimation = "BuildTowerAnimation",
	
	EnterDig = "EnterDig",
	ExitDig = "ExitDig",
	Dig = "Dig",
	
	Enter = "Enter",
	ArriveEnd = "ArriveEnd",
	Slide = "Slide",
	GetWins = "GetWins",
	Exit = "Exit",
	Reset = "Reset",
	
	LogGameProperty = "LogGameProperty",
}

return ClimbTowerDefine