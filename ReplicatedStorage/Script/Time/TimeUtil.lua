local Define = require(game.ReplicatedStorage.Define)

local TimeUtil = {}

function TimeUtil:GetNow(isUTC)
	local result
	if isUTC then
		result = os.date("!*t") 
	else
		result = os.date("*t") 
	end

	if Define.Test.EnableSignCurrentDate then
		result.year = Define.Test.CurrentDate.SignYear
		result.month =  Define.Test.CurrentDate.SignMonth
		result.day = Define.Test.CurrentDate.SignDay
		result.hour = Define.Test.CurrentDate.SignHour
		result.min = Define.Test.CurrentDate.SignMin
		result.sec = Define.Test.CurrentDate.SignSec
	end
	
	return result
	
	-- {year=2025, month=6, day=13, hour=13, min=22, sec=0, ...}
end

function TimeUtil:IsBetween(date, startDate, endDate)
	if endDate == nil then
		endDate = startDate
		startDate = date
		date = TimeUtil:GetNow()	
	end
	
	if startDate == nil or endDate == nil then
		return false
	end
	
	local dateTime = os.time{year=date.year, month=date.month, day=date.day, hour=0, min=0, sec=0 }
	local startTime = os.time{year=startDate.year, month=startDate.month, day=startDate.day, hour=0, min=0, sec=0 }
	local endTime = os.time{year=endDate.year, month=endDate.month, day=endDate.day, hour=0, min=0, sec=0 }
	return dateTime >= startTime and dateTime <= endTime
end

function TimeUtil:DaysBetween(date1, date2)
	if date1 == nil or date2 == nil  then
		return -1
	end
	local d1 = {
		year = date1.year,
		month = date1.month,
		day = date1.day,
		hour = 0,
		min = 0,
		sec = 0
	}
	local d2 = {
		year = date2.year,
		month = date2.month,
		day = date2.day,
		hour = 0,
		min = 0,
		sec = 0
	}

	local time1 = os.time(d1)
	local time2 = os.time(d2)
	local diffInSeconds = time2 - time1
	local result = math.floor(diffInSeconds / 86400)
	
	if result < 0 then result = -1 end
	-- 当天算1天
	result = result + 1
	return result
end

function TimeUtil:IsToday(date)
	local now = TimeUtil:GetNow()
	return not TimeUtil:IsDifferentDate(date, now)
end

function TimeUtil:IsCurrentWeek(date)
	if date == nil then
		return false
	end

	local now = TimeUtil:GetNow()
	local nowTime = os.time{year=now.year, month=now.month, day=now.day, hour=0, min=0, sec=0}
	local dateTime = os.time{year=date.year, month=date.month, day=date.day, hour=0, min=0, sec=0}
	local nowWeekDay = tonumber(os.date("%w", nowTime))
	if nowWeekDay == 0 then nowWeekDay = 7 end -- 把周日视为第7天
	local weekStart = nowTime - (nowWeekDay - 1) * 86400
	local weekEnd = weekStart + 6 * 86400
	return dateTime >= weekStart and dateTime <= weekEnd
end

function TimeUtil:IsCurrentMonth(date)
	if date == nil then
		return false
	end
	local now = TimeUtil:GetNow()
	return date.year == now.year and date.month == now.month
end

function TimeUtil:IsCurrentYear(date)
	if date == nil then
		return false
	end
	local now = TimeUtil:GetNow()
	return date.year == now.year
end

function TimeUtil:IsDifferentDate(date1, date2)
	if date1 == nil or date2 == nil then
		return false
	end
	return date1.year ~= date2.year or
		date1.month ~= date2.month or
		date1.day ~= date2.day
end

function TimeUtil:SecondsToNextHour()
	local now = os.time()
	local date = os.date("*t", now)

	date.min = 0
	date.sec = 0
	date.hour = date.hour + 1

	local nextHour = os.time(date)
	return os.difftime(nextHour, now)
end

function TimeUtil:SecondsToNextDay()
	local now = os.time()
	local date = os.date("*t", now)
	
	date.hour = 0
	date.min = 0
	date.sec = 0
	date.day = date.day + 1

	local nextDay = os.time(date)
	return os.difftime(nextDay, now)
end

function TimeUtil:FormatSeconds(seconds)
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = math.floor(seconds % 60)

	local function pad(n)
		return n < 10 and "0" .. n or tostring(n)
	end

	if h > 0 then
		return string.format("%d:%s:%s", h, pad(m), pad(s))
	else
		return string.format("%d:%s", m, pad(s))
	end
end

function TimeUtil:FormatMsToMMSSMS(ms)
	local minutes = math.floor(ms / (1000 * 60)) % 60
	local seconds = math.floor(ms / 1000) % 60
	local milliseconds = ms % 1000
	return string.format("%2d:%02d:%03d", minutes, seconds, milliseconds)
end

function TimeUtil:FormatMsToMMSS(ms)
	local minutes = math.floor(ms / (1000 * 60)) % 60
	local seconds = math.floor(ms / 1000) % 60
	return string.format("%2d:%02d", minutes, seconds)
end

function TimeUtil:AutoFormat(seconds)
	if seconds == nil or seconds < 0 then
		return "0 S"
	end

	local days = math.floor(seconds / 86400)
	local hours = math.floor((seconds % 86400) / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = math.floor(seconds % 60)

	local parts = {}

	if days > 0 then
		table.insert(parts, string.format("%d D", days))
	end
	if hours > 0 or days > 0 then
		table.insert(parts, string.format("%d H", hours))
	end
	if minutes > 0 or hours > 0 or days > 0 then
		table.insert(parts, string.format("%d M", minutes))
	end
	table.insert(parts, string.format("%d S", secs))

	return table.concat(parts, " ")
end

-- 将秒数格式化为 "xD xH xM xS"
function TimeUtil:FormatDuration(seconds)
	local days = math.floor(seconds / 86400)
	seconds = seconds % 86400
	local hours = math.floor(seconds / 3600)
	seconds = seconds % 3600
	local minutes = math.floor(seconds / 60)
	seconds = math.floor(seconds % 60)

	local parts = {}
	if days > 0 then table.insert(parts, days .. "D") end
	if hours > 0 or #parts > 0 then table.insert(parts, hours .. "H") end
	if minutes > 0 or #parts > 0 then table.insert(parts, minutes .. "M") end
	table.insert(parts, seconds .. "S")

	return table.concat(parts, " ")
end

-- 距离今天结束还有多久
function TimeUtil:GetLeftToday()
	local now = os.time()
	local date = os.date("*t", now)
	-- 当天 23:59:59
	local endOfDay = os.time({
		year = date.year,
		month = date.month,
		day = date.day,
		hour = 23,
		min = 59,
		sec = 59
	})
	local diff = endOfDay - now
	return self:FormatDuration(diff)
end

-- 距离本周结束（周日 23:59:59）还有多久
function TimeUtil:GetLeftWeek()
	local now = os.time()
	local date = os.date("*t", now)

	-- os.date("*t").wday: 1=周日, 2=周一, ..., 7=周六
	local daysToSunday = 8 - date.wday
	if daysToSunday == 7 then daysToSunday = 0 end -- 今天是周日

	local endOfWeek = os.time({
		year = date.year,
		month = date.month,
		day = date.day + daysToSunday,
		hour = 23,
		min = 59,
		sec = 59
	})

	local diff = endOfWeek - now
	return self:FormatDuration(diff)
end

-- 计算指定时间若干天后的时间
function TimeUtil:AddDays(inputDate, days)
	if inputDate == nil or days == nil then
		return nil
	end
	local dateTable = {
		year = inputDate.year or 1970,
		month = inputDate.month or 1,
		day = inputDate.day or 1,
		hour = inputDate.hour or 0,
		min = inputDate.min or 0,
		sec = inputDate.sec or 0
	}
	local baseTime = os.time(dateTable)
	local futureTime = baseTime + (days * 86400)
	local resultDate = os.date("*t", futureTime)
	return {
		year = resultDate.year,
		month = resultDate.month,
		day = resultDate.day,
		hour = resultDate.hour,
		min = resultDate.min,
		sec = resultDate.sec
	}
end

return TimeUtil
