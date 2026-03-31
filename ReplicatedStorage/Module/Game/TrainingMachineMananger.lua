local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local TrainingMachineMananger = {}

local TrainingMachineList = {}

function TrainingMachineMananger:Register(trainingMachineInfo)
	table.insert(TrainingMachineList, trainingMachineInfo)
end

function TrainingMachineMananger:Refresh(trainingMachineInfo)
	Util:ListRemoveWithCondition(TrainingMachineList, function(info) return info.Index == trainingMachineInfo.Index end)
	table.insert(TrainingMachineList, trainingMachineInfo)
end

function TrainingMachineMananger:GetBest()
	local enableList = Util:ListFindAll(TrainingMachineList, function(info) return not info.IsLock end)
	return Util:ListMax(enableList, function(info) return info.Data.RewardPower end)
end

return TrainingMachineMananger