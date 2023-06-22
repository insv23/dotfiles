-- Automatically reload the hammerspoon configuration file when changes are detected.
-- 检测到 hammerspoon 配置文件发生变动就自动重新加载配置文件
function reload(files)
    for _, file in pairs(files) do
      if file:sub(-4) == ".lua" then
        hs.notify.new({title='Reloading', informativeText='Reloading Hammerspoon config'}):send()
        hs.reload()
        return
      end
    end
  end
  
  reloadWatcher = hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', reload):start()