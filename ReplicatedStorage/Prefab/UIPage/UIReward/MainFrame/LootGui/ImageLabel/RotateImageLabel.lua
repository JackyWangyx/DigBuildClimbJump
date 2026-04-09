local imageLabel = script.Parent
local rotationSpeed = 1 -- degrees per frame

while true do
    imageLabel.Rotation = (imageLabel.Rotation + rotationSpeed) % 360
    task.wait(0.03) -- Adjust the wait time for smoother or faster rotation
end

