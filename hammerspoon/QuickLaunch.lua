-- 不要使用这个, 好多软件里都自定义了 alt + 其他键 作为快捷键, 例如 lazyvim
-- 使用 Raycast 来开启软件
-- hs.hotkey.bind({'alt'}, '1', function () hs.application.launchOrFocus("Google Chrome") end)
-- hs.hotkey.bind({'alt'}, '2', function () hs.application.launchOrFocus("Terminal") end)

hs.hotkey.bind({ "alt" }, "a", function()
	hs.application.launchOrFocus("Arc")
end)

hs.hotkey.bind({ "alt" }, "b", function()
	hs.application.launchOrFocus("BotGem")
end)

hs.hotkey.bind({ "alt" }, "c", function()
	hs.application.launchOrFocus("cursor")
end)

-- hs.hotkey.bind({'alt'}, 'e', function () hs.application.launchOrFocus("Finder") end)
hs.hotkey.bind({ "alt" }, "n", function()
	hs.application.launchOrFocus("Notion")
end)

hs.hotkey.bind({ "alt" }, "t", function()
	hs.application.launchOrFocus("Telegram")
end)

-- 与 shottr 的窗口截图冲突
-- hs.hotkey.bind({ "alt" }, "w", function()
-- 	hs.application.launchOrFocus("wechat")
-- end)

hs.hotkey.bind({ "alt" }, "k", function()
	hs.application.launchOrFocus("kitty")
end)

hs.hotkey.bind({ "ctrl", "alt" }, "forwarddelete", function()
	hs.application.launchOrFocus("Activity Monitor")
end)
