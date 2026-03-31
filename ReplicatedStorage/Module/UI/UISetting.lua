local UserSettingManager = require(game.ReplicatedStorage.ScriptAlias.UserSettingManager)

local UISetting = {}

UISetting.UIRoot = nil

function UISetting:Init(root)
	UISetting.UIRoot = root
end

function UISetting:OnShow()

end

function UISetting:OnHide()

end

function UISetting:Refresh()

end

return UISetting
