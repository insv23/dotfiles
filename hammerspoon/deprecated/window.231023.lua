hs.window.animationDuration = 0
-- half of screen
hs.hotkey.bind({'ctrl', 'alt'}, 'left', function() hs.window.focusedWindow():moveToUnit({0, 0, 0.5, 1}) end)
hs.hotkey.bind({'ctrl', 'alt'}, 'right', function() hs.window.focusedWindow():moveToUnit({0.5, 0, 0.5, 1}) end)
hs.hotkey.bind({'ctrl', 'alt'}, 'up', function() hs.window.focusedWindow():moveToUnit({0, 0, 1, 0.5}) end)
hs.hotkey.bind({'ctrl', 'alt'}, 'down', function() hs.window.focusedWindow():moveToUnit({0, 0.5, 1, 0.5}) end)

-- quarter of screen
hs.hotkey.bind({'ctrl', 'alt'}, 'u', function() hs.window.focusedWindow():moveToUnit({0, 0, 0.5, 0.5}) end) -- 左上
hs.hotkey.bind({'ctrl', 'alt'}, 'k', function() hs.window.focusedWindow():moveToUnit({0.5, 0.5, 0.5, 0.5}) end) -- 右下
hs.hotkey.bind({'ctrl', 'alt'}, 'i', function() hs.window.focusedWindow():moveToUnit({0.5, 0, 0.5, 0.5}) end) -- 右上
hs.hotkey.bind({'ctrl', 'alt'}, 'j', function() hs.window.focusedWindow():moveToUnit({0, 0.5, 0.5, 0.5}) end) -- 左下

-- full screen
hs.hotkey.bind({'ctrl', 'alt'}, 'return', function() hs.window.focusedWindow():moveToUnit({0, 0, 1, 1}) end)

-- center screen
hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, 'c', function() hs.window.focusedWindow():centerOnScreen() end)

-- move between displays
hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'right', function()
  local win = hs.window.focusedWindow()
  local next = win:screen():toEast()
  if next then
    win:moveToScreen(next, true)
  end
end)
hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'left', function()
  local win = hs.window.focusedWindow()
  local next = win:screen():toWest()
  if next then
    win:moveToScreen(next, true)
  end
end)

-- grid gui
hs.grid.setMargins({w = 0, h = 0})
hs.hotkey.bind({'shift', 'cmd'}, 'g', hs.grid.show)

-- auto layout
-- hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'l', function() autoLayout() end)

-- size for recording
hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'r', function()
  hs.window.focusedWindow():setSize({w = 640, h = 360})
end)