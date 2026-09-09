--- @since 25.5.31

local STATUS = {
    added = "A",
    conflict = "U",
    modified = "M",
    renamed = "R",
    untracked = "?",
}

local function render_status()
    if ui.render then
        ui.render()
    else
        ya.render()
    end
end

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

local function status_code(index_status, worktree_status)
    local status = index_status .. worktree_status
    if status:find("D", 1, true) then
        return nil
    elseif status == "??" then
        return STATUS.untracked
    elseif status:find("U", 1, true) then
        return STATUS.conflict
    elseif status:find("R", 1, true) then
        return STATUS.renamed
    elseif status:find("A", 1, true) then
        return STATUS.added
    else
        return STATUS.modified
    end
end

local function add_parent_status(changes, repository, relative_path, status)
    local file_url = repository:join(relative_path)
    changes[tostring(file_url)] = status

    local parent = file_url.parent
    while parent do
        changes[tostring(parent)] = STATUS.modified
        if parent == repository then
            break
        end
        parent = parent.parent
    end
end

local function parse_git_status(output, repository)
    local changes = {}

    for record in output:gmatch("[^%z]+") do
        local index_status = record:sub(1, 1)
        local worktree_status = record:sub(2, 2)
        local relative_path = record:sub(4):gsub("/$", "")
        local status = status_code(index_status, worktree_status)

        if status and relative_path ~= "" then
            add_parent_status(changes, repository, relative_path, status)
        end
    end

    return changes
end

local update_status = ya.sync(function(state, directory, repository, changes)
    state.directories[directory] = repository
    state.repositories[repository] = changes
    render_status()
end)

local clear_status = ya.sync(function(state, directory)
    local repository = state.directories[directory]
    if not repository then
        return
    end

    state.directories[directory] = nil

    for _, active_repository in pairs(state.directories) do
        if active_repository == repository then
            render_status()
            return
        end
    end

    state.repositories[repository] = nil
    render_status()
end)

local function setup(state, options)
    state.directories = {}
    state.repositories = {}

    options = options or {}
    options.order = options.order or 1500

    Linemode:children_add(function(file_line)
        local file_url = file_line._file.url
        local directory = tostring(file_url.base or file_url.parent)
        local repository = state.directories[directory]
        local statuses = repository and state.repositories[repository]
        local status = statuses and statuses[tostring(file_url)]

        if status then
            return ui.Line { " ", status }
        end

        return ""
    end, options.order)
end

--- Run one repository-wide status scan and refresh the visible Yazi rows.
local function fetch(_, job)
    local directory = job.files[1].url.base or job.files[1].url.parent
    local repository = find_git_root(directory)
    if not repository then
        clear_status(tostring(directory))
        return true
    end

    local output, error_message = Command("git")
        :cwd(tostring(repository))
        :arg({
            "--no-optional-locks",
            "status",
            "--porcelain=v1",
            "-z",
            "--untracked-files=all",
            "--no-renames",
        })
        :stdout(Command.PIPED)
        :output()

    if not output then
        ya.err("git-status: cannot read Git status: " .. tostring(error_message))
        return true
    end

    update_status(
        tostring(directory),
        tostring(repository),
        parse_git_status(output.stdout, repository)
    )
    return false
end

return { setup = setup, fetch = fetch }
