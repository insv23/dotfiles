-- 初始化变量保存剪贴板内容
local previousClipboardContents = hs.pasteboard.getContents()

-- 创建一个通知函数
local function showClipboardNotification()
    local currentClipboardContents = hs.pasteboard.getContents()
    if currentClipboardContents ~= previousClipboardContents then
        -- 显示通知
        hs.notify.new({
            title = "剪贴板内容已更改",
            informativeText = currentClipboardContents or "非文本内容",
            withdrawAfter = 1
        }):send()
        
        -- 更新保存的剪贴板内容
        previousClipboardContents = currentClipboardContents
    end
end

-- 设置一个定时器，每秒检查一次剪贴板内容
clipboardWatcher = hs.timer.doEvery(1, showClipboardNotification)

-- 启动 Hammerspoon 时立即检查一次剪贴板内容
showClipboardNotification()
