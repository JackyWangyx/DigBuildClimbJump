local Define = require(game.ReplicatedStorage.Define)

local UIWaitLoading = {}

UIWaitLoading.UIRoot = nil
UIWaitLoading.ShowAnimationType = "Fade"
UIWaitLoading.HideAnimationType = "Fade"

function UIWaitLoading:Init(root)
	UIWaitLoading.UIRoot = root
end

function UIWaitLoading:OnShow()

end

function UIWaitLoading:OnHide()

end

function UIWaitLoading:Refresh()

end

return UIWaitLoading