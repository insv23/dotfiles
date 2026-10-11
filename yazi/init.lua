require("git-status"):setup()

-- 右侧预览区点空白不再进入高亮的文件夹。
-- Yazi 内置的 preview.lua 把预览区的点击转成两条命令：点条目 reveal 到那个文件
-- （保留），点空白 enter 进当前高亮目录（去掉）。mouse_events 只能按事件种类开关，
-- 分不了是哪一栏，所以只能在这里覆盖；用户 init.lua 在所有内置组件之后加载，
-- 改这个全局表对已创建的实例也生效（Preview:new 走 __index 查表）。
function Preview:click(event, up)
    local y = event.y - self._area.y + 1
    local window = self._folder and self._folder.window or {}
    if not up and window[y] then
        Entity:new(window[y]):click(event, up)
    end
end

-- 关掉 eza 的 --git-ignore：被 .gitignore 命中的目录（如项目里的 datas/）
-- 否则整个目录被判为 ignore，右侧只显示 No items
require("eza-preview"):setup({
    git_ignore = false,
})

require("projects"):setup({
    save = {
        method = "yazi", -- yazi | lua
        yazi_load_event = "@projects-load", -- event name when loading projects in `yazi` method
        lua_save_path = "", -- path of saved file in `lua` method, comment out or assign explicitly
                            -- default value:
                            -- windows: "%APPDATA%/yazi/state/projects.json"
                            -- unix: "~/.local/state/yazi/projects.json"
    },
    last = {
        update_after_save = true,
        update_after_load = true,
        load_after_start = false,
    },
    merge = {
        event = "projects-merge",
        quit_after_merge = false,
    },
    event = {
        save = {
            enable = true,
            name = "project-saved",
        },
        load = {
            enable = true,
            name = "project-loaded",
        },
        delete = {
            enable = true,
            name = "project-deleted",
        },
        delete_all = {
            enable = true,
            name = "project-deleted-all",
        },
        merge = {
            enable = true,
            name = "project-merged",
        },
    },
    notify = {
        enable = true,
        title = "Projects",
        timeout = 3,
        level = "info",
    },
})
