#!/usr/bin/env zsh
# setup.zsh — 新机器初始化向导
# 交互式多选菜单，逐步安装 zsh 插件、vim 插件、Homebrew 及相关应用、tmux 插件。
# 用法：./setup.zsh
setopt NO_XTRACE

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# 每两项一对：描述 + 命令
steps=(
    "安装 ZSH 插件"       "./zsh/install_plugins.sh"
    "安装 Vim 插件"       "./vim/install_plugins.sh"
    "安装 Homebrew"       "./brew/0.install.sh"
    "安装 Homebrew 应用"  "./brew/1.brewInstallApps.sh"
    "安装 Tmux 插件"      "./tmux/install_tpm.sh"
)

n=$(( ${#steps} / 2 ))
typeset -a selected
for i in {1..$n}; do selected[$i]=0; done
current=1

draw_menu() {
    tput cup 0 0
    printf "${BOLD}新机器初始化向导${NC}\n"
    printf "${DIM}j/↓ 下移  k/↑ 上移  空格 选择/取消  回车 开始安装  Esc/q 退出${NC}\n\n"
    for i in {1..$n}; do
        local desc=${steps[$(( (i-1)*2 + 1 ))]}
        if [[ $i -eq $current && ${selected[$i]} -eq 1 ]]; then
            printf "\033[2K  ${YELLOW}▶${NC} ${GREEN}[✓]${NC} ${BOLD}${desc}${NC}\n"
        elif [[ $i -eq $current ]]; then
            printf "\033[2K  ${YELLOW}▶${NC} [ ] ${BOLD}${desc}${NC}\n"
        elif [[ ${selected[$i]} -eq 1 ]]; then
            printf "\033[2K    ${GREEN}[✓]${NC} ${desc}\n"
        else
            printf "\033[2K    [ ] ${desc}\n"
        fi
    done
}

execute_selected() {
    local any=0
    for i in {1..$n}; do
        [[ ${selected[$i]} -eq 0 ]] && continue
        any=1
        local desc=${steps[$(( (i-1)*2 + 1 ))]}
        local cmd=${steps[$(( (i-1)*2 + 2 ))]}
        printf "\n${YELLOW}[执行]${NC} ${BOLD}${desc}${NC}\n"
        printf "      → ${cmd}\n\n"
        if eval "$cmd"; then
            printf "${GREEN}✓ 完成${NC}\n"
        else
            printf "${RED}✗ 失败${NC}\n"
        fi
    done
    [[ $any -eq 0 ]] && printf "${DIM}未选择任何步骤，退出。${NC}\n"
}

tput smcup
tput civis
trap 'tput cnorm; tput rmcup; exit' INT TERM

draw_menu

while true; do
    read -sk1 key
    if [[ $key == $'\033' ]]; then
        read -sk1 -t 0.1 key2
        if [[ $? -ne 0 ]]; then
            # 单独的 Esc，直接退出
            tput cnorm; tput rmcup; exit 0
        fi
        if [[ $key2 == '[' ]]; then
            read -sk1 -t 0.1 key3
            case $key3 in
                A) key=k ;;
                B) key=j ;;
            esac
        fi
    fi
    case $key in
        j) (( current < n )) && (( current++ )) ;;
        k) (( current > 1 )) && (( current-- )) ;;
        q|Q) tput cnorm; tput rmcup; exit 0 ;;
        ' ') selected[$current]=$(( 1 - selected[$current] )) ;;
        $'\n'|$'\r') break ;;
    esac
    draw_menu
done

tput cnorm
tput rmcup
execute_selected
