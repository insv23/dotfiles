-- -- 每隔 27 分钟(1,620 秒)播放指定的音频文件以保证 Jamo 音箱不关机
local audioFile = "./audio/mouse-click.mp3"

-- 创建一个定时器，每隔 1620 秒触发一次
local timer = hs.timer.new(1620, function()
    -- 获取当前的音频输出设备
    local outputDevice = hs.audiodevice.defaultOutputDevice()

    -- 检查当前音频输出设备是否为"外置耳机"
    if outputDevice:name() == "外置耳机" then
        -- 播放指定的音频文件
        hs.sound.getByFile(audioFile):volume(0.05):play()
    end
end)

-- 启动定时器
timer:start()