local ProximityArea = {}

function ProximityArea:Handle(part, message, func)
	if not part then return end
	part.CanCollide = false
	part.CanTouch = true
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.Name = "ProximityPrompt"
	proximityPrompt.Parent = part
	proximityPrompt.ActionText = message
	--proximityPrompt.ObjectText = "ABC"
	proximityPrompt.UIOffset = Vector2.new(0, 35)
	local partSize = math.max(part.Size.X, math.max(part.Size.Y, part.Size.Z))
	proximityPrompt.MaxActivationDistance = partSize + 1
	proximityPrompt.Triggered:Connect(function()
		if not func then return end
		func()
	end)
	return proximityPrompt
end

return ProximityArea