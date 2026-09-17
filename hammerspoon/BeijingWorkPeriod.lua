-- Menu bar indicator for Beijing work hours.
-- This machine runs on Beijing time, so the local clock is the wall clock: no timezone
-- conversion is involved anywhere in this file.
-- Peak periods are weekdays 09:00-12:00 and 14:00-18:00, so the state only flips at the
-- four boundaries below.
local periodBoundaries = { "09:00", "12:00", "14:00", "18:00" }

-- Keep the menu, timers and wake watcher alive for the whole Hammerspoon session.
beijingWorkPeriodState = beijingWorkPeriodState or {}

if beijingWorkPeriodState.timers then
    for _, timer in ipairs(beijingWorkPeriodState.timers) do
        timer:stop()
    end
end
beijingWorkPeriodState.timers = {}

if beijingWorkPeriodState.wakeWatcher then
    beijingWorkPeriodState.wakeWatcher:stop()
end

if beijingWorkPeriodState.menu then
    beijingWorkPeriodState.menu:delete()
end

beijingWorkPeriodState.menu = hs.menubar.new()

local function isWorkPeak(now)
    local isWeekday = now.wday >= 2 and now.wday <= 6
    local isMorningPeak = now.hour >= 9 and now.hour < 12
    local isAfternoonPeak = now.hour >= 14 and now.hour < 18

    return isWeekday and (isMorningPeak or isAfternoonPeak)
end

local function updateBeijingWorkPeriodTitle()
    beijingWorkPeriodState.menu:setTitle(isWorkPeak(os.date("*t")) and "梁文峰" or "梁文谷")
end

local function scheduleBoundaryTimers()
    for _, timer in ipairs(beijingWorkPeriodState.timers) do
        timer:stop()
    end
    beijingWorkPeriodState.timers = {}

    for _, timeOfDay in ipairs(periodBoundaries) do
        -- Fires at that wall-clock time every day, until the next reload.
        local timer = hs.timer.doAt(timeOfDay, "1d", updateBeijingWorkPeriodTitle)
        table.insert(beijingWorkPeriodState.timers, timer)
    end
end

-- NSTimer pauses while the system sleeps, so a boundary crossing during sleep is missed.
-- Re-deriving the title on wake covers that gap.
beijingWorkPeriodState.wakeWatcher = hs.caffeinate.watcher.new(function(event)
    local happenedAtWake = event == hs.caffeinate.watcher.systemDidWake
        or event == hs.caffeinate.watcher.screensDidWake
        or event == hs.caffeinate.watcher.screensDidUnlock

    if happenedAtWake then
        updateBeijingWorkPeriodTitle()
        scheduleBoundaryTimers()
    end
end):start()

updateBeijingWorkPeriodTitle()
scheduleBoundaryTimers()
