-- Automatically reload the hammerspoon configuration file when changes are detected.
-- 检测到 hammerspoon 配置文件发生变动就自动重新加载配置文件

function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end

myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config reloaded", {
    atScreenEdge = 1, -- 0: screen center (default); 1: top edge; 2: bottom edge . 
})
