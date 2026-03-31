local TriggerArea = {}

local TriggerStateCache = {}

function TriggerArea:Handle(triggerArea, enterFunc, exitFunc, onlyLocalPlayer)
	if not triggerArea then return end
	-- 防止重复绑定
	if TriggerStateCache[triggerArea] then
		return
	end
	
	if onlyLocalPlayer == nil then
		onlyLocalPlayer = true
	end
	
	local localPlayer = game.Players.LocalPlayer
	local touchedCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	localPlayer.CharacterAdded:Connect(function(character)
		touchedCharacter = character
	end)
	
	local state = TriggerArea:GetTriggerPartCache(triggerArea)
	triggerArea.Touched:Connect(function(hitPart)
		if not TriggerArea:CheckCanHit(hitPart) then
			return
		end
		
		if onlyLocalPlayer and touchedCharacter ~= hitPart.Parent then
			return
		end
		
		local player = TriggerArea:GetPlayerByHitPart(hitPart)
		if not player then return end
		if not state[player] then
			state[player] = 0
		end
		state[player] += 1

		if state[player] == 1 and enterFunc then
			enterFunc()
		end
	end)

	triggerArea.TouchEnded:Connect(function(hitPart)
		if not TriggerArea:CheckCanHit(hitPart) then
			return
		end
		
		if onlyLocalPlayer and touchedCharacter ~= hitPart.Parent then
			return
		end
		
		local player = TriggerArea:GetPlayerByHitPart(hitPart)
		if not player then return end
		
		-- 延迟 0.1 秒检查
		task.delay(0.1, function()
			if state[player] then
				state[player] -= 1
				if state[player] == 0 then
					state[player] = nil
					if exitFunc then
						exitFunc(player)
					end
				end
			end
		end)
	end)
end

function TriggerArea:GetTriggerPartCache(part)
	if not part then return nil end
	local result = TriggerStateCache[part]
	if not result then
		result = {}
		TriggerStateCache[part] = result
	end
	return result
end

function TriggerArea:CheckCanHit(hitPart)
	return typeof(hitPart) == "Instance" and hitPart.Name == "UpperTorso"
end

function TriggerArea:GetPlayerByHitPart(hitPart)
	local model = hitPart:FindFirstAncestorOfClass("Model")
	if model then
		local humanoid = model:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			return model
		end
	end
	return nil
end

return TriggerArea
