-- -- ??? : 与 QuickLaunch, hold cmd Q 冲突，只要 他们 启动，该脚本就不正常工作
-- 参考: https://www.hammerspoon.org/go/#variablelife
-- 如果 jamoSoundTimer 是 local 变量, 在其他快捷键启动后会被销毁

-- -- 每隔 x 分钟播放指定的音频文件以保证 Jamo 音箱不关机
-- -- Jamo 音箱大概 29 mins 不出声就关机

-- 定义播放音频的时间间隔（以分钟为单位）
local INTERVAL_MINS = 27
local audioFile = "./audio/mouse-click.mp3"
local interval_seconds = 60 * INTERVAL_MINS

-- 播放音频文件的自定义函数
local function playAudioFile()
    local outputDeviceName = hs.audiodevice.defaultOutputDevice():name()
    
    -- 检查当前音频输出设备是否为"外置耳机"
    if outputDeviceName == "外置耳机" then
        -- 播放指定的音频文件
        hs.sound.getByFile(audioFile):volume(0.005):play()
    end
end

-- 创建一个定时器，每隔指定的秒数触发一次
jamoSoundTimer = hs.timer.doEvery(interval_seconds, playAudioFile)

-- 启动 Hammerspoon 时立即执行一次
playAudioFile()
