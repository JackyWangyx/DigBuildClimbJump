local UIIndexManager = {}

------------------------------------------------------------------------------------
-- UI 全局索引，缓存 UI 在启动时的完整结构信息，用于快速查找，包含所有UI界面的初始状态，但不包含动态加载的元素列表等。

------------------------------------------------------------------------------------
-- Build Index

local UIIndexMap = {}
local NodeIndexInfoMap = {}

local ClassHierarchy = {
	-- 基类
	GuiObject = {"GuiObject"},
	GuiBase2d = {"GuiBase2d"},

	-- 按钮类（重点）
	GuiButton = {"GuiButton", "GuiObject"},

	TextButton = {"TextButton", "GuiButton", "GuiObject"},
	ImageButton = {"ImageButton", "GuiButton", "GuiObject"},

	-- 显示类
	TextLabel = {"TextLabel", "GuiObject"},
	ImageLabel = {"ImageLabel", "GuiObject"},

	-- 输入类
	TextBox = {"TextBox", "GuiObject"},

	-- 容器类
	Frame = {"Frame", "GuiObject"},
	ScrollingFrame = {"ScrollingFrame", "GuiObject"},
	ViewportFrame = {"ViewportFrame", "GuiObject"},

	-- UI 控件
	VideoFrame = {"VideoFrame", "GuiObject"},

	-- 布局 / 约束（这些通常不用查，但可以加）
	UIListLayout = {"UIListLayout"},
	UIGridLayout = {"UIGridLayout"},
	UIPageLayout = {"UIPageLayout"},
	UITableLayout = {"UITableLayout"},
	UIAspectRatioConstraint = {"UIAspectRatioConstraint"},
	UISizeConstraint = {"UISizeConstraint"},
	UIStroke = {"UIStroke"},
	UICorner = {"UICorner"},
	UIPadding = {"UIPadding"},
	UIScale = {"UIScale"},
	UIGradient = {"UIGradient"},

	-- ScreenGui / Layer
	ScreenGui = {"ScreenGui"},
	BillboardGui = {"BillboardGui"},
	SurfaceGui = {"SurfaceGui"},
}

function UIIndexManager:BuildIndex(ui)
	local uiIndexInfo = {
		Root = ui,
		NameDic = {},
		TypeDic = {},
		TypeNameDic = {},
		NodeList = {},
	}
	
	local uiName = ui.Name
	UIIndexMap[ui] = uiIndexInfo
	
	UIIndexManager:BuildNodeInfo(ui, uiIndexInfo)
end

function UIIndexManager:BuildNodeInfo(node, uiIndexInfo)
	local NameDic = uiIndexInfo.NameDic
	local TypeDic = uiIndexInfo.TypeDic
	local TypeNameDic = uiIndexInfo.TypeNameDic
	local NodeList = uiIndexInfo.NodeList
	
	NodeIndexInfoMap[node] = node
	
	local typeName = node.ClassName
	local nodeName = node.Name

	-- Node List

	NodeList[#NodeList + 1] = node

	-- Name
	local nameList = NameDic[nodeName]
	if not nameList then
		nameList = {}
		NameDic[nodeName] = nameList
	end
	
	nameList[#nameList + 1] = node
	
	local subTypes = ClassHierarchy[typeName]
	if not subTypes then
		subTypes = {typeName} 
	end
	
	for i = 1, #subTypes do
		local subType = subTypes[i]
		
		-- Type
		local typeList = TypeDic[subType]
		if not typeList then
			typeList = {}
			TypeDic[subType] = typeList
		end

		typeList[#typeList + 1] = node
		
		-- Type and Name
		local typeNameDic = TypeNameDic[subType]
		if not typeNameDic then
			typeNameDic = {}
			TypeNameDic[subType] = typeNameDic
		end

		local typeNameList = typeNameDic[nodeName]
		if not typeNameList then
			typeNameList = {}
			typeNameDic[nodeName] = typeNameList
		end

		typeNameList[#typeNameList + 1] = node
	end
	
	local childList = node:GetChildren()
	for i = 1, #childList do
		local child = childList[i]
		UIIndexManager:BuildNodeInfo(child, uiIndexInfo)
	end
end

function UIIndexManager:GetIndexByUIRoot(ui)
	local uiIndexInfo = UIIndexMap[ui]
	return uiIndexInfo
end

function UIIndexManager:GetIndexByUINode(uiNode)
	local nodeIndexInfo = NodeIndexInfoMap[uiNode]
	return nodeIndexInfo
end

------------------------------------------------------------------------------------
-- Foreach

function UIIndexManager:ForeachInNode(uiNode, func)
	local nodeIndexInfo = UIIndexManager:GetIndexByUINode(uiNode)
	if nodeIndexInfo then
		local nodeList = nodeIndexInfo.UIIndexInfo.NodeList
		for index = nodeIndexInfo.StartIndex, nodeIndexInfo.EndIndex do
			local node = nodeList[index]
			func(node)
		end
	else
		local childList = uiNode:GetDescendants()
		for i = 1, #childList do
			local child = childList[i]
			func(child)
		end
	end
end

------------------------------------------------------------------------------------
-- Search Name

function UIIndexManager:GetChildByName(uiNode, partName)
	local nodeIndexInfo = UIIndexManager:GetIndexByUINode(uiNode)
	if not nodeIndexInfo then return nil end
	local list = nodeIndexInfo.NameDic[partName]
	if not list then return nil end
	return list[1]
end

function UIIndexManager:GetAllChildByName(ui, partName)
	local nodeIndexInfo = UIIndexManager:GetIndexByUI(ui)
	if not nodeIndexInfo then return nil end
	local list = nodeIndexInfo.NameDic[partName]
	return list
end

------------------------------------------------------------------------------------
-- Search Type

function UIIndexManager:GetChildByType(uiNode, typeName)
	local nodeIndexInfo = UIIndexManager:GetIndexByUINode(uiNode)
	if not nodeIndexInfo then return nil end
	local list = nodeIndexInfo.TypeDic[typeName]
	if not list then return nil end
	return list[1]
end

function UIIndexManager:GetAllChildByType(uiNode, typeName)
	local nodeIndexInfo = UIIndexManager:GetIndexByUINode(uiNode)
	if not nodeIndexInfo then return nil end
	local list = nodeIndexInfo.TypeDic[typeName]
	return list
end

------------------------------------------------------------------------------------
-- Search Type and Name

function UIIndexManager:GetChildByTypeAndName(uiNode, typeName, partName)
	local nodeIndexInfo = UIIndexManager:GetIndexByUINode(uiNode)
	if not nodeIndexInfo then return nil end
	local dic = nodeIndexInfo.TypeNameDic[typeName]
	if not dic then return nil end
	local list = dic[partName] 
	if not list then return nil end
	return list[1]
end

function UIIndexManager:GetAllChildByTypeAndName(uiNode, typeName, partName)
	local nodeIndexInfo = UIIndexManager:GetIndexByUINode(uiNode)
	if not nodeIndexInfo then return nil end
	local dic = nodeIndexInfo.TypeNameDic[typeName]
	if not dic then return nil end
	local list = dic[partName] 
	if not list then return nil end
	return list
end

------------------------------------------------------------------------------------
-- Search Path

--function UIIndexManager:GetChildByPath(uiNode, path)
--	-- TODO
--end

return UIIndexManager
