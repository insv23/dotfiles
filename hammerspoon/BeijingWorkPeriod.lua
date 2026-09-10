local beijingTimeOffset = 8 * 60 * 60
local workPeriodMenu = hs.menubar.new()

local function updateWorkPeriodTitle()
    local beijingTime = os.date("!*t", os.time() + beijingTimeOffset)
    local isWeekday = beijingTime.wday >= 2 and beijingTime.wday <= 6
    local isMorningPeak = beijingTime.hour >= 9 and beijingTime.hour < 12
    local isAfternoonPeak = beijingTime.hour >= 14 and beijingTime.hour < 18

    if isWeekday and (isMorningPeak or isAfternoonPeak) then
        workPeriodMenu:setTitle("梁文峰")
    else
        workPeriodMenu:setTitle("梁文谷")
    end
end

updateWorkPeriodTitle()
hs.timer.doEvery(60, updateWorkPeriodTitle)
