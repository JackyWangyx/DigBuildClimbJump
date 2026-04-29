local Tweener = require(script.Parent.Tweener)

local TweenPool = {}

local PoolCache = {}

function TweenPool:Spawn()
	if #PoolCache > 0 then
		local tweener = table.remove(PoolCache)
		return tweener
	else
		local tweener = Tweener.new()
		tweener.RecycleToPool = function()
			TweenPool:DeSpawn(tweener)
		end
		
		return tweener
	end
end

function TweenPool:DeSpawn(tweener)
	table.insert(PoolCache, tweener)
end

return TweenPool