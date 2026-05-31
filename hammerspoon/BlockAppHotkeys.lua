-- App-scoped hotkey blockers.
-- Swallow dangerous shortcuts only while matching apps are frontmost.

local M = {}

local blockedHotkeys = {
  {
    bundleID = "com.iamcorey.kooky",
    modifiers = { "cmd" },
    key = "w",
    message = "已屏蔽 Kooky Cmd+W",
  },
  {
    bundleID = "com.iamcorey.kooky",
    modifiers = { "cmd", "shift" },
    key = "w",
    message = "已屏蔽 Kooky Cmd+Shift+W",
  },
}

local activeHotkeys = {}

local function hotkeyID(rule)
  return table.concat(rule.modifiers, "+") .. "+" .. rule.key .. "@" .. rule.bundleID
end

local function currentBundleID()
  local app = hs.application.frontmostApplication()
  return app and app:bundleID()
end

local function setRuleEnabled(rule, enabled)
  local id = hotkeyID(rule)
  local hotkey = activeHotkeys[id]

  if not hotkey then
    hotkey = hs.hotkey.new(rule.modifiers, rule.key, function()
      if rule.message then hs.alert(rule.message, 0.4) end
    end)
    activeHotkeys[id] = hotkey
  end

  if enabled then
    hotkey:enable()
  else
    hotkey:disable()
  end
end

local function refresh()
  local bundleID = currentBundleID()
  for _, rule in ipairs(blockedHotkeys) do
    setRuleEnabled(rule, bundleID == rule.bundleID)
  end
end

M.watcher = hs.application.watcher.new(function()
  refresh()
end)

M.watcher:start()
refresh()

return M
