local RunService = game:GetService("RunService")

local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIPropItem = require(game.ReplicatedStorage.ScriptAlias.UIPropItem)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local UIPropList = {}

UIPropList.Root = nil

function UIPropList:Init(root)
	UIPropList.Root = root.Layout
	for _, child in ipairs(UIPropList.Root:GetChildren()) do
		if child:IsA("Frame") then
			UIPropItem:Init(child)
		end
	end
	
	EventManager:Listen(EventManager.Define.RefreshProp, function()
		UIPropList:Refresh()
	end)
	
	UIPropList:Refresh()
end

function UIPropList:RefreshList()
	NetClient:Request("Prop", "GetPackageList", function(packageList)
		for _, child in ipairs(UIPropList.Root:GetChildren()) do
			if child:IsA("Frame") then
				local name = child.Name
				local key = string.match(name, "_(.+)$")
				local propData = ConfigManager:SearchData("Prop", "ProductKey", key)
				if propData then
					UIInfo:SetInfo(child, propData)	
					local propInfo = Util:ListFind(packageList, function(info) 
						return info.ID == propData.ID
					end)

					if not propInfo then
						propInfo = {
							Count = 0,
						}
					end
					UIInfo:SetInfo(child, propInfo)
				end
			end
		end
	end)
end

function UIPropList:Refresh()
	UIPropList:RefreshList()
end

return UIPropList
