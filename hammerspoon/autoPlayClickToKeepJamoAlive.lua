-- -- ??? : 与 QuickLaunch, hold cmd Q 冲突，只要 他们 启动，该脚本就不正常工作

-- -- 每隔 x 分钟播放指定的音频文件以保证 Jamo 音箱不关机
-- -- Jamo 音箱大概 29 mins 不出声就关机
local INTERVAL_MINS = 27
local audioFile = "./audio/mouse-click.mp3"
local interval_seconds = 60*INTERVAL_MINS

-- 导入Hammerspoon模块
local timer = require "hs.timer"
local notify = require "hs.notify"
local sound = require "hs.sound"

-- 创建一个定时器，每隔 x 秒触发一次
local soundTimer = timer.new(interval_seconds, function()
    
    local outputDeviceName = hs.audiodevice.defaultOutputDevice():name()

    -- 创建一个通知
    -- notify.new({title=outputDeviceName, informativeText=""}):send()
    
    -- 检查当前音频输出设备是否为"外置耳机"
    if outputDeviceName == "外置耳机" then
        -- 播放指定的音频文件
        sound.getByFile(audioFile):volume(0.05):play()
        -- notify.new({title='Jamo', informativeText='is Click'}):send()
    end
end)

-- 启动定时器
soundTimer:start()