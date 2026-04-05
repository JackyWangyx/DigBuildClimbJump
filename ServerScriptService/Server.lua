local Define = require(game.ReplicatedStorage.Define)

local function Init()
	require(game.ReplicatedStorage.ScriptAlias.LogUtil):Init()
	require(game.ServerScriptService.ScriptAlias.NetServer):Init()
	
	-- Data
	require(game.ServerScriptService.ScriptAlias.ServerPrefs):Init()
	require(game.ServerScriptService.ScriptAlias.PlayerPrefs):Init()
	require(game.ServerScriptService.ScriptAlias.PlayerCache):Init()
	require(game.ServerScriptService.ScriptAlias.PlayerStatus):Init()
	require(game.ServerScriptService.ScriptAlias.PlayerProperty):Init()
	require(game.ServerScriptService.ScriptAlias.PlayerLeaderStats):Init()
	require(game.ServerScriptService.ScriptAlias.PlayerHud):Init()
	require(game.ServerScriptService.ScriptAlias.PlayerRecord):Init()
	require(game.ServerScriptService.ScriptAlias.GameRank):Init()

	-- System
	require(game.ServerScriptService.ScriptAlias.IAPServer):Init()
	require(game.ReplicatedStorage.ScriptAlias.SceneManager):Init()

	require(game.ReplicatedStorage.ScriptAlias.PlayerManager):Init()
	require(game.ServerScriptService.ScriptAlias.MessageManager):Init()
	require(game.ServerScriptService.ScriptAlias.DataStorageManager):Init()
	require(game.ServerScriptService.ScriptAlias.MemoryStoreManager):Init()
	require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager):Init()
	require(game.ServerScriptService.ScriptAlias.QuestManager):Init()

	-- System
	require(game.ServerScriptService.ScriptAlias.TradeServer):Init()
	require(game.ReplicatedStorage.ScriptAlias.FriendManager):Init()

	-- GamePlay
	require(game.ReplicatedStorage.ScriptAlias.DriveController):Init()
	require(game.ServerScriptService.ScriptAlias.PetServerHandler):Init()
	require(game.ServerScriptService.ScriptAlias.BuffOnlineHandler):Init()
	require(game.ServerScriptService.ScriptAlias.ToolServerHandler):Init()
	require(game.ServerScriptService.ScriptAlias.EquipmentServerHandler):Init()
	require(game.ServerScriptService.ScriptAlias.TrailServerHandler):Init()
	require(game.ServerScriptService.ScriptAlias.PropServerHandler):Init()
	require(game.ServerScriptService.ScriptAlias.TrainingHandler) :Init()
	require(game.ServerScriptService.ScriptAlias.AutoRebirthHandler):Init()
	--require(game.ServerScriptService.ScriptAlias.RunnerGameHandler):Init()
	--require(game.ServerScriptService.ScriptAlias.AnimalServerHandler):Init()
	require(game.ServerScriptService.ScriptAlias.PartnerServerHandler):Init()

	
	require(game.ServerScriptService.ScriptAlias.SceneAreaServerHandler):Init()
	
	require(game.ServerScriptService.ScriptAlias.ClimbTowerServer):Init()

	-- Misc
	require(game.ServerScriptService.Debug.DebugServer):Init()

	print("[Server] Start! Ver : "..Define.Version)
end

Init()