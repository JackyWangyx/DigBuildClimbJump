local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local AttributeUtil = require(game.ReplicatedStorage.ScriptAlias.AttributeUtil)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local UIListSelect = require(game.ReplicatedStorage.ScriptAlias.UIListSelect)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local UIConfirm = require(game.ReplicatedStorage.ScriptAlias.UIConfirm)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local BuildManager = require(game.ReplicatedStorage.ScriptAlias.BuildManager)
local BuildUtil = require(game.ReplicatedStorage.ScriptAlias.BuildUtil)
local BuildDefine = require(game.ReplicatedStorage.ScriptAlias.BuildDefine)

local Define = require(game.ReplicatedStorage.Define)

local UIBuildPartStore = {}

UIBuildPartStore.UIRoot = nil

function UIBuildPartStore:Init(root)
	UIBuildPartStore.UIRoot = root
end

function UIBuildPartStore:OnShow(param)

end

function UIBuildPartStore:OnHide()

end

function UIBuildPartStore:Refresh()
	
end

return UIBuildPartStore
