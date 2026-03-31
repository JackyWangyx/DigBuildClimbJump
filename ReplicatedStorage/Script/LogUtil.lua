local RunService = game:GetService("RunService")

local LogUtil = {}

LogUtil.LogType = {
	Log = 1,
	Warn = 2,
	Error = 3,
}

local EnablePrefix = false

local IsStudio = nil
local IsClient = nil
local IsServer = nil

local ClientIcon = "🖥️"
local ServerIcon = "📶"

local LogPrefix = {
	[LogUtil.LogType.Log]   = "ℹ️ ",
	[LogUtil.LogType.Warn]  = "⚠️ ",
	[LogUtil.LogType.Error] = "❌ ",
}

local LogLevel = 1

function LogUtil:Init()
	IsStudio = RunService:IsStudio()
	IsClient = RunService:IsClient()
	IsServer = RunService:IsServer()
	if IsStudio then
		LogLevel = LogUtil.LogType.Log
	else
		LogLevel = LogUtil.LogType.Warn
	end
end

function LogUtil:SetLogLevel(level)
	LogLevel = level
end

function LogUtil:Log(...)
	LogUtil:LogWithType(LogUtil.LogType.Log, ...)
end

function LogUtil:Warn(...)
	LogUtil:LogWithType(LogUtil.LogType.Warn, ...)
end

function LogUtil:Error(title, ...)
	LogUtil:LogWithType(LogUtil.LogType.Error, ...)
end

function LogUtil:LogWithType(logType, ...)
	if logType < LogLevel then return end
	local args = {...}
	for index, value in ipairs(args) do
		args[index] = tostring(value)
	end
	
	local message = table.concat(args, " ")
	--local timeStamp = os.date("[%H:%M:%S] ")
	local icon = ""
	if IsClient then
		icon = ClientIcon
	else
		icon = ServerIcon
	end
	local outputText = ""
	if EnablePrefix then
		outputText = icon .. LogPrefix[logType]
	end
	outputText = outputText .. message
	if logType == LogUtil.LogType.Log then
		print(outputText)
	elseif logType == LogUtil.LogType.Warn then
		warn(outputText)
	elseif logType == LogUtil.LogType.Error then
		error(outputText)
	end
end

return LogUtil
