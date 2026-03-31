local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function GetUILoading()
	local player = game.Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	local uiLoadingPrefab = ReplicatedFirst.Prefab.UILoading
	local ui = uiLoadingPrefab:Clone()
	ui.Parent = playerGui
	return ui
end

local function Loading()
	ReplicatedFirst:RemoveDefaultLoadingScreen()
	local uiLoading = GetUILoading()
	uiLoading.Enabled = true

	ReplicatedFirst:ClearAllChildren()
end

Loading()