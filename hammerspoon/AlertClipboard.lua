-- 紧凑右侧剪贴板提醒（支持图片）- 使用 hs.pasteboard.watcher
-- 参考: [hs.pasteboard.watcher.new()](hammerspoon/AlertClipboard.lua:22) 文档用法（自动启动或手动 :start()）

-- alert.show 参数
-- hs.alert.show(str, [style], [screen], [seconds]) -> uuid
local duration = 0.8

-- 提示样式：更小且固定在屏幕右侧
-- https://github.com/Hammerspoon/hammerspoon/blob/master/extensions/alert/alert.lua#L17
local alertStyleRightSmall = {
  atScreenEdge  = 2,                       -- 0: screen center (default); 1: top edge; 2: bottom edge . Note when atScreenEdge>0, the latest alert will overlay above the previous ones if multiple alerts visible on same edge; and when atScreenEdge=0, latest alert will show below previous visible ones without overlap.
  textSize      = 12,                      -- 字体更小
  radius        = 8,                       -- 圆角更小
  strokeWidth   = 1,                       -- 细边
  strokeColor   = { white = 1, alpha = 0.9 },
  fillColor     = { white = 0, alpha = 0.85 },
  textColor     = { white = 1, alpha = 1 },
  -- 可选：textFont = "SF Pro Text", textStyle = { bold = false }
}

-- 配置粘贴板轮询间隔（仅影响新建 watcher；默认 0.25s）
-- 如需更省电可提高到 0.5 或 1.0
-- hs.pasteboard.watcher.interval(0.25)

-- ===== 文本整形配置（可统一调整） =====
local LongTextConfig = { -- [lua.LongTextConfig](hammerspoon/AlertClipboard.lua:1)
  maxLineChars = 50,      -- 每行最多字符数
  tailChars = 10,         -- 行内溢出时，尾部保留字符数
  ellipsis = "......",    -- 行内与中间折叠的省略标记
  maxVisibleLines = 5,    -- 总行数阈值：<=5 不折叠，>5 执行折叠
  headVisibleLines = 2,   -- 折叠时保留的头部行数
  tailVisibleLines = 2,   -- 折叠时保留的尾部行数
}

-- 图片尺寸限制配置（可统一调整）
local ImageClampConfig = { -- [lua.ImageClampConfig](hammerspoon/AlertClipboard.lua:1)
  maxWidth = 600,   -- 最大宽度
  maxHeight = 400,  -- 最大高度
}

-- 根据最大宽高等比缩放图片；若无需缩放则原样返回
local function clampImage(img, cfg) -- [lua.clampImage()](hammerspoon/AlertClipboard.lua:1)
  cfg = cfg or ImageClampConfig
  if not img or not img.size then return img end
  local sz = img:size()
  if not sz or not sz.w or not sz.h or sz.w == 0 or sz.h == 0 then return img end
  local scale = math.min(cfg.maxWidth / sz.w, cfg.maxHeight / sz.h, 1.0)
  if scale >= 1.0 then return img end
  local newSize = { w = math.floor(sz.w * scale), h = math.floor(sz.h * scale) }
  return img:setSize(newSize)
end

-- UTF-8 安全长度
local function utf8_len(s) -- [lua.utf8_len()](hammerspoon/AlertClipboard.lua:1)
  local ok, len = pcall(utf8.len, s)
  if ok and len then return len end
  return #s
end

-- UTF-8 安全子串（基于代码点，支持负索引）
local function utf8_sub(s, i, j) -- [lua.utf8_sub()](hammerspoon/AlertClipboard.lua:1)
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

-- 按“行内限制”裁剪一行：头部 + ellipsis + 尾部(tailChars)，总长不超过 maxLineChars
local function truncateLineByCols(line, cfg) -- [lua.truncateLineByCols()](hammerspoon/AlertClipboard.lua:1)
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

-- 将原始文本拆分为行（兼容 CRLF）
local function splitLines(s) -- [lua.splitLines()](hammerspoon/AlertClipboard.lua:1)
  s = s:gsub("\r\n", "\n"):gsub("\r", "\n")
  local lines = {}
  for line in s:gmatch("([^\n]+)") do
    table.insert(lines, line)
  end
  if #lines == 0 then table.insert(lines, "") end
  return lines
end

-- 按“行数折叠策略”折叠：n > maxVisibleLines 时保留头2行 + 一行省略 + 尾2行
local function foldByLines(lines, cfg) -- [lua.foldByLines()](hammerspoon/AlertClipboard.lua:1)
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
local function formatLongText(s, cfg) -- [lua.formatLongText()](hammerspoon/AlertClipboard.lua:1)
  cfg = cfg or LongTextConfig
  local rawLines = splitLines(s)
  local clipped = {}
  for _, line in ipairs(rawLines) do
    table.insert(clipped, truncateLineByCols(line, cfg))
  end
  local folded = foldByLines(clipped, cfg)
  return table.concat(folded, "\n")
end

-- 使用官方 watcher 监测剪贴板变化
-- 回调参数 text: 若内容可作为字符串读取则为字符串，否则为 nil
-- 图片检测仍需通过 hs.pasteboard.readImage()
alertClipboardPBWatcher = hs.pasteboard.watcher.new(function(text)
  -- 优先尝试读取图片
  local img = hs.pasteboard.readImage()
  if img then
    -- 复制了图片：按最大宽高等比缩放后展示
    local scaled = clampImage(img, ImageClampConfig) -- [lua.clampImage()](hammerspoon/AlertClipboard.lua:1)
    hs.alert.showWithImage("", scaled or img, alertStyleRightSmall, hs.screen.mainScreen(), duration)
    return
  end

  -- 非图片：使用回调 text 或兜底读取文本；应用行宽与行数折叠策略
  local msg = text or hs.pasteboard.getContents() or "已复制非文本内容"
  local display = formatLongText(msg, LongTextConfig) -- [lua.formatLongText()](hammerspoon/AlertClipboard.lua:1)
  hs.alert.show(display, alertStyleRightSmall, hs.screen.mainScreen(), duration)
end)

-- 显式启动（部分版本 new() 已自动 start，这里兼容性起见手动再启动一次）
alertClipboardPBWatcher:start()