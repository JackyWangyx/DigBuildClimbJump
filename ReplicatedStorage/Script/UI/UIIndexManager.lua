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
	
	local nodeIndexInfo = {
		UIIndexInfo = uiIndexInfo,
		StartIndex = #NodeList + 1,
		EndIndex = 0,
	}
	
	NodeIndexInfoMap[node] = nodeIndexInfo
	
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
	
	nodeIndexInfo.EndIndex = #NodeList
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

-- 根据索引范围过滤搜索自身的所有子节点
local function FliterSubNode(uiNode, nodeList, onlyFirst)
	if not nodeList then
		if onlyFirst then
			return nil
		else
			return {}
		end
	end
	
	local nodeIndexInfo = UIIndexManager:GetIndexByUINode(uiNode)
	local uiIndexInfo = nodeIndexInfo.UIIndexInfo
	local isRoot = uiIndexInfo.Root == uiNode
	
	if isRoot then
		-- 如果是根节点，则直接搜索所有
		if onlyFirst then
			return nodeList[1]
		else
			return nodeList
		end
	else
		-- 如果不是根节点，则需根据索引范围过滤
		local startIndex = nodeIndexInfo.StartIndex
		local endIndex = nodeIndexInfo.EndIndex

		local result = nil
		if not onlyFirst then
			result = {}
		end
		
		for index = 1, #nodeList do
			local node = nodeList[index]
			local nodeIndex = NodeIndexInfoMap[node].StartIndex
			if nodeIndex >= startIndex and nodeIndex <= endIndex then
				if onlyFirst then 
					result = node
					break
				else
					result[#result + 1] = node
				end
			end
		end
		
		return result
	end
end

------------------------------------------------------------------------------------
-- Search Name

function UIIndexManager:GetChildByName(uiNode, partName)
	local nodeIndexInfo = NodeIndexInfoMap[uiNode]
	if not nodeIndexInfo then return nil end
	local uiIndexInfo = nodeIndexInfo.UIIndexInfo
	local nodeList = uiIndexInfo.NameDic[partName]

	local result = FliterSubNode(uiNode, nodeList, true)
	return result
end

function UIIndexManager:GetAllChildByName(uiNode, partName)
	local nodeIndexInfo = NodeIndexInfoMap[uiNode]
	if not nodeIndexInfo then return nil end
	local uiIndexInfo = nodeIndexInfo.UIIndexInfo
	local nodeList = uiIndexInfo.NameDic[partName]

	local result = FliterSubNode(uiNode, nodeList, false)
	return result
end

------------------------------------------------------------------------------------
-- Search Type

function UIIndexManager:GetChildByType(uiNode, typeName)
	local nodeIndexInfo = NodeIndexInfoMap[uiNode]
	if not nodeIndexInfo then return nil end
	local uiIndexInfo = nodeIndexInfo.UIIndexInfo
	local nodeList = uiIndexInfo.TypeDic[typeName]
	
	local result = FliterSubNode(uiNode, nodeList, true)
	return result
end

function UIIndexManager:GetAllChildByType(uiNode, typeName)
	local nodeIndexInfo = NodeIndexInfoMap[uiNode]
	if not nodeIndexInfo then return nil end
	local uiIndexInfo = nodeIndexInfo.UIIndexInfo
	local nodeList = uiIndexInfo.TypeDic[typeName]

	local result = FliterSubNode(uiNode, nodeList, false)
	return result
end

------------------------------------------------------------------------------------
-- Search Type and Name

function UIIndexManager:GetChildByTypeAndName(uiNode, typeName, partName)
	local nodeIndexInfo = NodeIndexInfoMap[uiNode]
	if not nodeIndexInfo then return nil end
	local uiIndexInfo = nodeIndexInfo.UIIndexInfo
	local nodeDic = uiIndexInfo.TypeNameDic[typeName]
	if not nodeDic then return nil end
	local nodeList = nodeDic[partName]

	local result = FliterSubNode(uiNode, nodeList, true)
	return result
end

function UIIndexManager:GetAllChildByTypeAndName(uiNode, typeName, partName)
	local nodeIndexInfo = NodeIndexInfoMap[uiNode]
	if not nodeIndexInfo then return nil end
	local uiIndexInfo = nodeIndexInfo.UIIndexInfo
	local nodeDic = uiIndexInfo.TypeNameDic[typeName]
	if not nodeDic then return nil end
	local nodeList = nodeDic[partName]
	
	local result = FliterSubNode(uiNode, nodeList, false)
	return result
end

------------------------------------------------------------------------------------
-- Search Path

--function UIIndexManager:GetChildByPath(uiNode, path)
--	-- TODO
--end

return UIIndexManager
