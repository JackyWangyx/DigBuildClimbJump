local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)

local GameLoader = {}

function GameLoader:Init()
	-- 等待游戏加载完成
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end
	
	-- 等待玩家存档加载完成
	local count = 1
	local isSaveLoaded = false
	while true do
		NetClient:Request("Player", "CheckSaveLoaded", function(result)
			isSaveLoaded = result
		end)
		task.wait(0.2)
		count += 1
		if isSaveLoaded then
			break
		end
	end
end

return GameLoader
