--How to use

--local timer = require(game.ReplicatedStorage.ScriptAlias.TimerManager)

--timer:After(1, function()
--	print(1)
--end)

--timer:After(5, function()
--	print(5)
--end)

local TimerData = require(game.ReplicatedStorage.ScriptAlias.TimerData)

-- 公共接口
local TimerManager = {}

function TimerManager:Create(duration, callback, options)
	local timer = TimerData.New(duration, callback, options)
	return timer
end

function TimerManager:After(duration, callback)
	local timer = TimerData.New(duration, callback)
	timer:Start()
	return timer
end

function TimerManager:Interval(duration, callback, options)
	options = options or {}
	options.loop = true
	if options.loopCount then
		options.loop = false
	end
	local timer = TimerData.New(duration, callback, options)
	timer:Start()
	return timer
end

return TimerManager