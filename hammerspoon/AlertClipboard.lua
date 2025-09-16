--[[
  剪贴板提醒（支持文本与图片）

  功能：
    - 监听系统剪贴板变化，弹出提示：
      * 文本：按行内长度与总行数进行格式化展示
      * 图片：按最大宽高等比缩放后展示

  使用：
    - 将本文件放入 ~/.hammerspoon/ 并在 init.lua 中加载(`require("AlertClipboard")`)
  
  说明：
    - 脚本加载时自动启动 watcher
    - 全局变量 alertClipboardPBWatcher 可用于手动停止/启动
    - 新增配置项 Config.duplicates.showOnDuplicate：
      * true：无论内容是否与上一次相同，只要再次复制就显示（默认）
      * false：相同内容重复复制将不显示（去重模式）
      * 文本按原文精确匹配去重；图片使用近似签名（优先编码字符串，回退尺寸）进行去重
]]

-- ========== 全局配置 ==========
local Config = {
  -- 重复复制是否也显示（默认显示）
  duplicates = {
    showOnDuplicate = true, -- true：不管是否与上次相同，都显示；false：相同则不显示
  },

  -- 弹窗显示时长（单位：秒）
  durations = {
    textSeconds = 2.5,   -- 文本提示持续时间
    imageSeconds = 0.8,  -- 图片提示持续时间
  },

  -- 剪贴板监听轮询间隔（秒）
  -- 说明：在创建 watcher 前设置。默认 0.25（等同 Hammerspoon 默认）
  pasteboard = {
    pollInterval = 0.25, -- 可改为 0.5 / 1.0 等以更省电
  },

  -- 提示样式（详见 Hammerspoon alert 模块）
  -- atScreenEdge: 0=屏幕中心；1=顶部；2=底部
  alertStyle = {
    atScreenEdge = 1,
    textSize     = 12, -- 更小的字体
    radius       = 8,  -- 更小的圆角
    strokeWidth  = 1,  -- 细边
    strokeColor  = { white = 1, alpha = 0.9 },
    fillColor    = { white = 0, alpha = 0.85 },
    textColor    = { white = 1, alpha = 1 },
    -- 可选：textFont = "SF Pro Text", textStyle = { bold = false }
  },

  -- 文本整形策略
  longText = {
    maxLineChars     = 50,       -- 每行最多字符数
    tailChars        = 10,       -- 行内溢出时，尾部保留字符数
    ellipsis         = "......", -- 省略标记（用于行内和中间折叠）
    maxVisibleLines  = 5,        -- 总行数阈值：超过则折叠
    headVisibleLines = 2,        -- 折叠时保留的头部行数
    tailVisibleLines = 2,        -- 折叠时保留的尾部行数
  },

  -- 图片尺寸限制（按最大宽高等比缩放）
  imageClamp = {
    maxWidth  = 300, -- 最大宽度
    maxHeight = 200, -- 最大高度
  },
}
-- ========== 结束：全局配置 ==========

-- 设置剪贴板 watcher 的轮询间隔（默认 0.25）
hs.pasteboard.watcher.interval(Config.pasteboard.pollInterval)

-- ========== 工具函数 ==========

-- UTF-8 安全长度
local function utf8_len(s)
  local ok, len = pcall(utf8.len, s)
  if ok and len then return len end
  return #s
end

-- UTF-8 安全子串（基于代码点，支持负索引）
local function utf8_sub(s, i, j)
  local function normIndex(str, idx)
    local len = utf8_len(str)
    if idx == nil then return nil end
    if idx < 0 then idx = len + 1 + idx end
    if idx < 1 then idx = 1 end
    if idx > len then idx = len end
    return idx
  end
  i = normIndex(s, i or 1)
  j = normIndex(s, j or -1)
  if i > j then return "" end
  local iByte = utf8.offset(s, i)
  local jByte = utf8.offset(s, j + 1)
  if not iByte then return "" end
  if not jByte then return s:sub(iByte) end
  return s:sub(iByte, jByte - 1)
end

-- 将原始文本拆分为行（兼容 CRLF）
local function splitLines(s)
  s = s:gsub("\r\n", "\n"):gsub("\r", "\n")
  local lines = {}
  for line in s:gmatch("([^\n]+)") do
    table.insert(lines, line)
  end
  if #lines == 0 then table.insert(lines, "") end
  return lines
end

-- 按“行内限制”裁剪一行：头部 + ellipsis + 尾部(tailChars)
local function truncateLineByCols(line, cfg)
  local maxCols = cfg.maxLineChars
  local tailKeep = cfg.tailChars
  local ell = cfg.ellipsis

  local len = utf8_len(line)
  if len <= maxCols then return line end

  local ellLen = utf8_len(ell)
  local headKeep = maxCols - tailKeep - ellLen
  if headKeep < 0 then headKeep = 0 end

  local head = utf8_sub(line, 1, headKeep)
  local tail = utf8_sub(line, -tailKeep)
  return head .. ell .. tail
end

-- 按“行数折叠策略”折叠
local function foldByLines(lines, cfg)
  local n = #lines
  if n <= cfg.maxVisibleLines then
    return lines
  end
  local out = {}
  for i = 1, math.min(cfg.headVisibleLines, n) do
    table.insert(out, lines[i])
  end
  table.insert(out, cfg.ellipsis)
  for i = math.max(1, n - cfg.tailVisibleLines + 1), n do
    table.insert(out, lines[i])
  end
  return out
end

-- 面向字符串的最终格式化：逐行裁列，再按行数折叠
local function formatLongText(s, cfg)
  cfg = cfg or Config.longText
  local rawLines = splitLines(s)
  local clipped = {}
  for _, line in ipairs(rawLines) do
    table.insert(clipped, truncateLineByCols(line, cfg))
  end
  local folded = foldByLines(clipped, cfg)
  return table.concat(folded, "\n")
end

-- 根据最大宽高等比缩放图片；若无需缩放则原样返回
local function clampImage(img, cfg)
  cfg = cfg or Config.imageClamp
  if not img or not img.size then return img end
  local sz = img:size()
  if not sz or not sz.w or not sz.h or sz.w == 0 or sz.h == 0 then return img end
  local scale = math.min(cfg.maxWidth / sz.w, cfg.maxHeight / sz.h, 1.0)
  if scale >= 1.0 then return img end
  local newSize = { w = math.floor(sz.w * scale), h = math.floor(sz.h * scale) }
  return img:setSize(newSize)
end

-- 生成图片的“近似签名”用于去重（优先编码字符串，失败时回退到尺寸）
local function imageSignature(img)
  if not img then return nil end
  local ok, str = pcall(function() return img:encodeAsURLString() end)
  if ok and type(str) == "string" then
    -- 仅取前缀作为签名，避免占用过多内存
    return string.sub(str, 1, 256)
  end
  local sz = img:size()
  if sz and sz.w and sz.h then
    return string.format("W%sxH%s", tostring(sz.w), tostring(sz.h))
  end
  return "unknown-image"
end

-- ========== 业务逻辑 ==========

-- 最近一次内容签名（用于可选的重复去重）
local lastTextSig = nil
local lastImageSig = nil

-- 剪贴板变更回调
local function onPasteboardChange(text)
  -- 优先尝试读取图片
  local img = hs.pasteboard.readImage()
  if img then
    if not Config.duplicates.showOnDuplicate then
      local sig = imageSignature(img)
      if sig and sig == lastImageSig then
        return
      end
      lastImageSig = sig
      lastTextSig = nil -- 不同类型切换时重置另一种签名
    end

    local scaled = clampImage(img, Config.imageClamp)
    hs.alert.showWithImage("", scaled or img, Config.alertStyle, hs.screen.mainScreen(), Config.durations.imageSeconds)
    return
  end

  -- 非图片：使用回调 text 或兜底读取文本；应用行宽与行数折叠策略
  local msg = text or hs.pasteboard.getContents() or "已复制非文本内容"

  if not Config.duplicates.showOnDuplicate then
    if msg == lastTextSig then
      return
    end
    lastTextSig = msg
    lastImageSig = nil
  end

  local display = formatLongText(msg, Config.longText)
  hs.alert.show(display, Config.alertStyle, hs.screen.mainScreen(), Config.durations.textSeconds)
end

-- 若已存在同名 watcher，先安全停止，避免重复
if type(alertClipboardPBWatcher) == "userdata" and alertClipboardPBWatcher.stop then
  pcall(function() alertClipboardPBWatcher:stop() end)
end

-- 创建并启动 watcher
alertClipboardPBWatcher = hs.pasteboard.watcher.new(onPasteboardChange)
-- 兼容：部分版本 new() 已自动 start，这里手动再启动一次（不会产生副作用）
alertClipboardPBWatcher:start()