local DataUpgradeManager = {}

function DataUpgradeManager:CheckUpgradeServer(saveInfo, targetVersion)
	if not saveInfo then return end
	local currentVersion = saveInfo.VersionCode
	if currentVersion == targetVersion then
		return
	end
end

function DataUpgradeManager:CheckUpgradePlayer(saveInfo, targetVersion)
	if not saveInfo then return end
	local currentVersion = saveInfo.VersionCode
	if currentVersion == targetVersion then
		return
	end
end

return DataUpgradeManager
