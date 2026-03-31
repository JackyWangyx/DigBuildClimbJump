local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)

local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local DebugServer = {}

local GameOwenrIdList = {
	8131012789, --babon5566
	9549385692,--birdge585
	7551903224, --babon0309
	-2,
	-3,
	-4,
	-5,
	-6,
	7552000724, -- ls9512
}

function DebugServer:Init()
	game.Players.PlayerAdded:Connect(function(player)
		local isOwner = DebugServer:IsGameOwner(player)
		if not isOwner then
			return
		end

		DebugServer:InitServer(player)
	end)
end

function DebugServer:IsGameOwner(player)
	local userID = player.UserId
	if Util:ListContains(GameOwenrIdList, userID) then
		return true
	end
	
	if PlayerManager:IsProjectOwner(player) then
		return true
	end
	return false
end

function DebugServer:InitServer(player)
	player.Chatted:Connect(function(message)
		if not message then
			return
		end
		if Util:IsStrStartWith(message, "/") then
			message = message:sub(2)
			message = DebugServer:Format(message)
			local words = {}
			for word in message:gmatch("%S+") do
				table.insert(words, word)
			end

			local module = ""
			local action = ""
			local param = nil
			for i, word in ipairs(words) do
				if i == 1  then
					module = word
				elseif i == 2  then
					action = word
				elseif i == 3  then
					param = word
				end
			end

			DebugServer:ExecuteCommand(player, module, action, param)
		end
	end)
end

function DebugServer:ExecuteCommand(player, module, action, param)
	local isOwner = DebugServer:IsGameOwner(player)
	if not isOwner then return end
	local moduleFolder = script.Parent.Command
	local moduleScript = require(moduleFolder:WaitForChild(module))
	local result = true
	if not moduleScript then
		result = false
	end

	local actionFunc = moduleScript[action]
	if not actionFunc or type(actionFunc) ~= "function" then
		result = false
	end

	actionFunc(moduleScript, player, param)
	if result then
		print("[Debug] ["..module.."/"..action.."] execute success.")
	else
		warn("[Debug] ["..module.."/"..action.."] not found!")
	end
	return result
end

function DebugServer:Format(message)
	local words = {}
	for word in message:gmatch("%S+") do
		local first = word:sub(1, 1):upper()
		local rest = word:sub(2):lower()
		table.insert(words, first .. rest)
	end
	return table.concat(words, " ")
end

return DebugServer