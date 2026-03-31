local PluginManagerWindow = require(game.ReplicatedStorage.Plugins.Script.PluginManagerWindow)

local Toolbar = plugin:CreateToolbar("Plugin")
local OpenButton = Toolbar:CreateButton("Plugin Manager", "Open Plugin Manager", "rbxassetid://4458901886")

local WindowInstance = nil

OpenButton.Click:Connect(function()
	if not WindowInstance then
		WindowInstance = PluginManagerWindow:CreateWindow(plugin)
	else
		WindowInstance.Enabled = not WindowInstance.Enabled 
	end	
end)