#!/bin/zsh

# 交互式选择安装
echo "请选择要安装的软件（可多选，用空格分隔）："
echo ""
echo "1. Caddy"
if command -v caddy >/dev/null 2>&1; then
    echo "   └── 已安装: $(which caddy)"
fi
echo ""
echo "2. Docker"
if command -v docker >/dev/null 2>&1; then
    echo "   └── 已安装: $(which docker)"
fi
echo ""
echo "3. Fail2Ban"
if command -v fail2ban-server >/dev/null 2>&1; then
    echo "   └── 已安装: $(which fail2ban-server)"
fi
echo ""

vared -p "请输入选择（例如：1 2）：" -c choices  # 使用 zsh 的 vared 命令

# 将用户输入转换为数组
selected=(${(s: :)choices})  # 使用 zsh 的字符串分割语法

# ---- caddy ----
if [[ " ${selected[@]} " =~ " 1 " ]]; then
    echo "🔻正在安装 Caddy..."
    sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
    sudo apt update
    sudo apt install caddy -y
    echo "✅Caddy 安装完成"
fi

# ---- docker ----
if [[ " ${selected[@]} " =~ " 2 " ]]; then
    echo "❓自动安装有问题，参考下列文档手动安装:"
    echo "https://github.com/insv23/dotfiles/blob/main/brew/UbuntuDocker.md"
fi

# ---- fail2ban ----
if [[ " ${selected[@]} " =~ " 3 " ]]; then
    echo "🔻正在安装 Fail2Ban..."
    sudo apt update
    sudo apt install fail2ban -y
    echo "✅Fail2Ban 安装完成"
fi

echo "✅✅✅✅安装完成✅✅✅✅"