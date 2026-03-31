local BanUserList = {}

BanUserList.IDList = {
	["2396802437"] = true,		-- Joaovitor196z6
}

function BanUserList:IsBan(playerID)
	local result = BanUserList.IDList[tostring(playerID)]
	if not result then return false end
	return result
end

return BanUserList
