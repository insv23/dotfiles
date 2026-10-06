-- Menu bar indicator for Beijing work hours.
-- This machine runs on Beijing time, so the local clock is the wall clock and no timezone
-- conversion is involved. Peak hours are weekdays 09:00-12:00 and 14:00-18:00.
--
-- The title is a pure function of the clock, so it can only change at the four boundaries.
-- One timer chained to the next boundary is enough; no polling.

local peakBoundaries = { 9, 12, 14, 18 } -- hours at which the title flips

local menu = hs.menubar.new()
local pendingTimer

local function isWorkPeak(t)
    local isWeekday = t.wday >= 2 and t.wday <= 6
    local isMorningPeak = t.hour >= 9 and t.hour < 12
    local isAfternoonPeak = t.hour >= 14 and t.hour < 18

    return isWeekday and (isMorningPeak or isAfternoonPeak)
end

local function secondsUntilNextBoundary()
    local now = os.date("*t")
    local nowSeconds = now.hour * 3600 + now.min * 60 + now.sec

    for _, hour in ipairs(peakBoundaries) do
        local delta = hour * 3600 - nowSeconds
        if delta > 0 then return delta end
    end

    return 24 * 3600 - nowSeconds + peakBoundaries[1] * 3600
end

local function refreshTitle()
    -- +1s grace: NSTimer may fire up to 1s early (see the notes on hs.timer.doAt), which
    -- would sample the previous hour and freeze the wrong title until the next boundary.
    menu:setTitle(isWorkPeak(os.date("*t", os.time() + 1)) and "梁文峰" or "梁文谷")

    -- Chain to the next boundary. A one-shot NSTimer whose fire date passed during sleep
    -- fires as soon as the run loop resumes, so a missed boundary self-corrects on wake.
    if pendingTimer then pendingTimer:stop() end
    pendingTimer = hs.timer.doAfter(secondsUntilNextBoundary(), refreshTitle)
end

-- Safety net for clock changes that do not come with a boundary crossing.
hs.caffeinate.watcher.new(function(event)
    local woke = event == hs.caffeinate.watcher.systemDidWake
        or event == hs.caffeinate.watcher.screensDidWake
        or event == hs.caffeinate.watcher.screensDidUnlock

    if woke then refreshTitle() end
end):start()

refreshTitle()
