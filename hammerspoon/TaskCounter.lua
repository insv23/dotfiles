local taskCounterSettingKey = "taskCounter.count"
local taskCounter = hs.settings.get(taskCounterSettingKey) or 0
local taskCounterMenu = hs.menubar.new()

local function updateTaskCounterTitle()
    taskCounterMenu:setTitle("✓ " .. taskCounter)
    hs.settings.set(taskCounterSettingKey, taskCounter)
end

taskCounterMenu:setClickCallback(function(modifiers)
    if modifiers.shift then
        taskCounter = 0
    elseif modifiers.alt then
        taskCounter = math.max(0, taskCounter - 1)
    else
        taskCounter = taskCounter + 1
    end
    updateTaskCounterTitle()
end)

taskCounterMenu:setTooltip("任务计数器：点击 +1；Option 点击 -1；Shift 点击归零")
updateTaskCounterTitle()
