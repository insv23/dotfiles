local function finderPath()
	local script = [[
tell application "Finder"
	if (count of Finder windows) > 0 then
		return POSIX path of (target of front Finder window as alias)
	else
		return POSIX path of (path to desktop folder as alias)
	end if
end tell
]]
	local ok, path = hs.osascript.applescript(script)
	if ok then
		return path
	end
	return nil
end

local finderCopyPathHotkey = hs.hotkey.new({ "cmd", "shift" }, "c", function()
	local path = finderPath()
	if path then
		hs.pasteboard.setContents(path)
	end
end)

local function updateFinderHotkey(app)
	if app and app:bundleID() == "com.apple.finder" then
		finderCopyPathHotkey:enable()
	else
		finderCopyPathHotkey:disable()
	end
end

updateFinderHotkey(hs.application.frontmostApplication())

finderCopyPathWatcher = hs.application.watcher.new(function(_, event, app)
	if event == hs.application.watcher.activated then
		updateFinderHotkey(app)
	end
end)

finderCopyPathWatcher:start()
