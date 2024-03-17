-- Hold Cmd q to quit App

-- config: number of seconds to hold Command-Q to quit application
cmdQDelay = 0.5

cmdQTimer = nil
cmdQAlert = nil

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
  cmdQTimer = hs.timer.doAfter(cmdQDelay, function() app:kill(); cmdQCleanup() end)
  cmdQAlert = hs.alert("hold to quit " .. app:name(), true)
end

cmdQ = hs.hotkey.bind({"cmd"},"q",startCmdQ,stopCmdQ)