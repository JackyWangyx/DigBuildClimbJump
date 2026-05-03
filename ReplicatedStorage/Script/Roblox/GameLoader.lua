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
		local getResult = false
		NetClient:Request("Player", "CheckSaveLoaded", function(result)
			isSaveLoaded = result
			getResult = true
		end)
		
		while not getResult do
			task.wait()
		end
		
		count += 1
		if isSaveLoaded then
			break
		else
			task.wait()
		end
	end
end

return GameLoader
