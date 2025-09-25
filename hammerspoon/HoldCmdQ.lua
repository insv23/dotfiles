-- Hold Cmd q to quit App

-- config: number of seconds to hold Command-Q to quit application
cmdQDelay = 0.5

cmdQTimer = nil
cmdQAlert = nil

-- Block list by bundle ID: apps here will have Cmd+Q disabled
-- Default: Screen Sharing
cmdQBlockBundleIDs = {
  ["com.apple.ScreenSharing"] = true,
}

local function isCmdQBlocked(app)
  if not app then return false end
  local bid = app:bundleID()
  if not bid then return false end
  return cmdQBlockBundleIDs[bid] == true
end

function cmdQCleanup()
  hs.alert.closeSpecific(cmdQAlert)
  cmdQTimer = nil
  cmdQAlert = nil
end

function stopCmdQ()
  if cmdQTimer then
    cmdQTimer:stop()
    cmdQCleanup()
    hs.alert("quit canceled",0.5)
  end
end

function startCmdQ()
  local app = hs.application.frontmostApplication()
  if isCmdQBlocked(app) then
    hs.alert("已屏蔽 Cmd+Q：" .. app:name(), 0.8)
    return
  end
  cmdQTimer = hs.timer.doAfter(cmdQDelay, function() app:kill(); cmdQCleanup() end)
  cmdQAlert = hs.alert("hold to quit " .. app:name(), true)
end

cmdQ = hs.hotkey.bind({"cmd"},"q",startCmdQ,stopCmdQ)
