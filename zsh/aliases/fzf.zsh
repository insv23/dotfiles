#!/bin/zsh
# fzf 交互函数：模糊搜索安装 Brew 包、终止进程、切换 Git 分支等

# fls: 展示本文件所有 fzf 别名及其说明
fls() {
    grep '^# f' ~/.dotfiles/zsh/aliases/fzf.zsh | sed 's/^# //' | fzf
}

# ---- Brew ----

# fbrs: 选择 brew 包并安装，[Tab 多选，Enter 确认]，右侧显示包描述
alias fbrs='{ brew formulae; brew casks; } | fzf -m --preview "brew info {}" | xargs brew install'

# fbrup: 从有新版本的包（含 cask）中选择并升级，[Tab 多选，Enter 确认]
fbrup() {
    local pkgs
    pkgs=$({ brew outdated --formula; brew outdated --cask; } | fzf -m --preview 'brew info {}')
    [[ -n "$pkgs" ]] && echo "$pkgs" | xargs brew upgrade
}

# fbrui: 从已安装的包（含 cask）中选择并卸载，[Tab 多选，Enter 确认]
fbrui() {
    local pkgs
    pkgs=$({ brew list --formula; brew list --cask; } | fzf -m --preview 'brew info {}')
    [[ -n "$pkgs" ]] && echo "$pkgs" | xargs brew uninstall
}

# fkill: 选择进程并 kill（默认 SIGTERM，传参数可指定信号，如 fkill -9）
fkill() {
    local pid
    pid=$(ps aux | fzf --header-lines=1 | awk '{print $2}')
    [[ -n "$pid" ]] && kill "${1:--15}" "$pid"
}


# ---- Git ----

# fgco: 选择本地分支并 checkout，按最近提交时间排序
fgco() {
    local branch
    branch=$(git for-each-ref --sort=-committerdate refs/heads/ \
        --format='%(refname:short) %(committerdate:relative) %(authorname)' \
        | fzf --preview 'git log --oneline --color=always {1}' \
        | awk '{print $1}')
    [[ -n "$branch" ]] && git checkout "$branch"
}

# fgadd: 选择 git 改动文件并 add，[Tab 多选，Enter 确认]
fgadd() {
    local files
    files=$(git status --short | fzf -m --preview 'git diff --color=always {2}' | awk '{print $2}')
    [[ -n "$files" ]] && echo "$files" | xargs git add
}

# fglog: 浏览 git log，右侧显示 diff，选中后输出 commit hash
fglog() {
    git log --oneline --color=always \
        | fzf --ansi --preview 'git show --color=always {1}' \
        | awk '{print $1}'
}

# fgst: 浏览 stash 列表，右侧显示 diff，回车应用选中的 stash
fgst() {
    local stash
    stash=$(git stash list \
        | fzf --preview 'git stash show --color=always -p {1}' \
        | cut -d: -f1)
    [[ -n "$stash" ]] && git stash apply "$stash"
}


# ---- Docker ----

# fdka: 选择容器并 start + attach
fdka() {
    local cid
    cid=$(docker ps -a | sed 1d | fzf --header-lines=0 -q "$1" | awk '{print $1}')
    [[ -n "$cid" ]] && docker start "$cid" && docker attach "$cid"
}

# fdks: 选择运行中的容器并 stop
fdks() {
    local cid
    cid=$(docker ps | sed 1d | fzf -q "$1" | awk '{print $1}')
    [[ -n "$cid" ]] && docker stop "$cid"
}

# fdkrm: 选择容器并删除，[Tab 多选，Enter 确认]
fdkrm() {
    docker ps -a | sed 1d | fzf -m --tac \
        | awk '{print $1}' | xargs -r docker rm
}

# fdkrmi: 选择镜像并删除，[Tab 多选，Enter 确认]
fdkrmi() {
    docker images | sed 1d | fzf -m --tac \
        | awk '{print $3}' | xargs -r docker rmi
}
