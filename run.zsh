#!/usr/bin/env zsh

# 定义颜色变量 / Define colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 定义命令数组 / Define commands array
commands=(
    "./zsh/install_plugins.sh"
    "./vim/install_plugins.sh"
    "./brew/0.install.sh"
    "./brew/1.brewInstallApps.sh"
    "./tmux/install_plugins.sh"
)

# 命令描述数组 / Define descriptions for each command
descriptions=(
    "安装 ZSH 插件(by git) / Install ZSH plugins"
    "安装 Vim 插件(by git) / Install Vim plugins"
    "安装 Homebrew / Install Homebrew"
    "通过 Homebrew 安装应用 / Install applications via Homebrew"
    "安装 Tmux 插件(需要先保证 tmux 已安装) / Install Tmux plugins"
)

# 执行命令的函数 / Function to execute commands
execute_command() {
    local cmd=$1
    echo "${YELLOW}执行命令 / Executing: ${NC}$cmd"
    if eval "$cmd"; then
        echo "${GREEN}命令执行成功 / Command completed successfully${NC}"
    else
        echo "${RED}命令执行失败 / Command failed${NC}"
        return 1
    fi
}

# 主循环 / Main loop
for i in {1..${#commands[@]}}; do
    echo "\n${YELLOW}[$i/${#commands[@]}] ${NC}${descriptions[$i]}"
    echo "命令 / Command: ${commands[$i]}"
    
    while true; do
        echo -n "是否执行此命令？(y/n/q 退出) / Execute this command? (y/n/q to quit): "
        read -r response
        
        case "$response" in
            [yY])
                execute_command "${commands[$i]}"
                break
                ;;
            [nN])
                echo "跳过 / Skipping..."
                break
                ;;
            [qQ])
                echo "退出脚本 / Exiting script..."
                exit 0
                ;;
            *)
                echo "请输入 y, n 或 q / Please enter y, n or q"
                ;;
        esac
    done
done

echo "\n${GREEN}所有命令处理完成 / All commands processed${NC}"