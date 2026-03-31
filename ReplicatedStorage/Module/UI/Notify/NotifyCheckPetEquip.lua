local UINotify = require(game.ReplicatedStorage.ScriptAlias.UINotify)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local TimerManager = require(game.ReplicatedStorage.ScriptAlias.TimerManager)
local TimeUtil = require(game.ReplicatedStorage.ScriptAlias.TimeUtil)

local NotifyCheckPetEquip = {}

function NotifyCheckPetEquip:Handle(rootPart)
	local notifyPart = rootPart:WaitForChild("Notify")
	local function refresh()
		NetClient:RequestQueue({
			{ Module = "Pet", Action = "GetEquipMax" },
			{ Module = "Pet", Action = "GetEquipCount" },
			{ Module = "Pet", Action = "GetPackageCount"}
		}, function(result)
			local equipMax = result[1]
			local equipCount = result[2]
			local packageCount = result[3]
			local result =  equipMax > equipCount and packageCount > equipCount
			notifyPart.Visible = result
		end)
	end

	refresh()

	EventManager:Listen(EventManager.Define.RefreshPet, function()
		refresh()
	end)
end

return NotifyCheckPetEquip
