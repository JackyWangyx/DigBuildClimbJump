local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIPropList = require(game.ReplicatedStorage.ScriptAlias.UIPropList)
local PetUtil = require(game.ReplicatedStorage.ScriptAlias.PetUtil)
local BigNumber = require(game.ReplicatedStorage.ScriptAlias.BigNumber)

local Define = require(game.ReplicatedStorage.Define)

local UIDonate = {}

UIDonate.UIRoot = nil

function UIDonate:Init(root)
	UIDonate.UIRoot = root
end

function UIDonate:OnShow(param)

end

function UIDonate:OnHide()

end

function UIDonate:Refresh()
	
end

--------------------------------------------------
-- Button

function UIDonate:Button_Donate1()
	UIDonate:DoateImpl(1)
end

function UIDonate:Button_Donate2()
	UIDonate:DoateImpl(2)
end

function UIDonate:Button_Donate3()
	UIDonate:DoateImpl(3)
end

function UIDonate:Button_Donate4()
	UIDonate:DoateImpl(4)
end

function UIDonate:Button_Donate5()
	UIDonate:DoateImpl(5)
end

function UIDonate:Button_Donate6()
	UIDonate:DoateImpl(6)
end

function UIDonate:Button_Donate7()
	UIDonate:DoateImpl(7)
end

function UIDonate:Button_Donate8()
	UIDonate:DoateImpl(8)
end

--------------------------------------------------
-- Internal

function UIDonate:DoateImpl(level)
	IAPClient:Purchase("Donate" .. level, function(success)
		if success then
			UIManager:ShowMessage(Define.Message.DonateSuccess)
		end
	end)
end

return UIDonate
