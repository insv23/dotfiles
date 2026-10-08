-- 此插件已停用，不要重新启用，也不要照它的做法再写一个。
-- 它接管右侧预览区，而 Yazi 的预览器是首个命中即止，自定义预览器会整体盖掉内置预览（图片、视频、PDF、code）。
-- 已观察到的后果：目录预览空白、图片预览失效，逐一打补丁只是把问题往后推。
-- 入口注册已从 yazi.toml 移除（原为 prepend_previewers 里的 mime = "text/*" 那条）；文件列表的行尾 Git 标记由 git-status 插件负责，与这里无关。

--- @since 25.5.31

local function find_git_root(directory)
    while directory do
        local git_directory = directory:join(".git")
        local metadata = fs.cha(git_directory)
        if metadata and metadata.is_dir then
            return directory
        end
        directory = directory.parent
    end
end

local function run_git(repository, arguments)
    local output = Command("git")
        :cwd(tostring(repository))
        :arg(arguments)
        :stdout(Command.PIPED)
        :output()

    return output and output.stdout or ""
end

local function split_lines(text)
    local lines = {}
    for line in (text .. "\n"):gmatch("(.-)\n") do
        local plain_line = line:gsub("\27%[[0-9;]*m", "")
        local metadata = plain_line:match("^diff %-%-git ")
            or plain_line:match("^index ")
            or plain_line:match("^--- ")
            or plain_line:match("^%+%+%+ ")
            or plain_line:match("^@@ ")
            or plain_line:match("^\\ No newline at end of file$")
        if not metadata then
            lines[#lines + 1] = line
        end
    end
    return lines
end

local function render_lines(job, output)
    local lines = split_lines(output)
    local start = job.skip + 1
    local finish = math.min(#lines, start + job.area.h - 1)

    if start > #lines and job.skip > 0 then
        ya.emit("peek", {
            math.max(0, #lines - job.area.h),
            only_if = job.file.url,
            upper_bound = true,
        })
        return
    end

    local visible = {}
    for i = start, finish do
        visible[#visible + 1] = lines[i]
    end

    ya.preview_widget(
        job,
        ui.Text.parse(table.concat(visible, "\n"))
            :area(job.area)
            :wrap(rt.preview.wrap == "yes" and ui.Wrap.YES or ui.Wrap.NO)
    )
end

local function file_relative_path(file_url, repository)
    return tostring(file_url):sub(#tostring(repository) + 2)
end

local function git_diff(repository, file_url)
    local relative_path = file_relative_path(file_url, repository)
    local diff = run_git(repository, {
        "-c",
        "color.ui=always",
        "-c",
        "color.diff.old=red",
        "-c",
        "color.diff.new=green",
        "-c",
        "color.diff.meta=cyan",
        "-c",
        "color.diff.frag=cyan",
        "diff",
        "HEAD",
        "--no-ext-diff",
        "--color=always",
        "--no-renames",
        "--unified=1000000",
        "--",
        relative_path,
    })

    if diff ~= "" then
        return diff
    end

    local untracked = run_git(repository, {
        "ls-files",
        "--others",
        "--exclude-standard",
        "--",
        relative_path,
    })
    if untracked == "" then
        return nil
    end

    return run_git(repository, {
        "-c",
        "color.ui=always",
        "-c",
        "color.diff.old=red",
        "-c",
        "color.diff.new=green",
        "-c",
        "color.diff.meta=cyan",
        "-c",
        "color.diff.frag=cyan",
        "diff",
        "--no-index",
        "--no-ext-diff",
        "--color=always",
        "--unified=1000000",
        "/dev/null",
        tostring(file_url),
    })
end

local function peek(_, job)
    if job.file.cha.is_dir then
        return require("eza-preview"):peek(job)
    end

    local repository = find_git_root(job.file.url.parent)
    if not repository then
        return require("code"):peek(job)
    end

    local diff = git_diff(repository, job.file.url)
    if not diff then
        return require("code"):peek(job)
    end

    if diff:find("Binary files", 1, true) then
        return require("code"):peek(job)
    end

    render_lines(job, diff)
end

local function seek(_, job)
    ya.emit("peek", {
        math.max(0, cx.active.preview.skip + job.units),
        only_if = job.file.url,
    })
end

return { peek = peek, seek = seek }
