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
    echo "🔻正在安装 Docker..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # 将当前用户添加到 docker 组来避免使用 docker 时必须加上 sudo
    sudo usermod -aG docker $USER

    # 重新加载用户组使其生效
    exec zsh  # 使用 exec zsh 代替 newgrp
    echo "✅Docker 安装完成"
fi

# ---- fail2ban ----
if [[ " ${selected[@]} " =~ " 3 " ]]; then
    echo "🔻正在安装 Fail2Ban..."
    sudo apt update
    sudo apt install fail2ban -y
    echo "✅Fail2Ban 安装完成"
fi

echo "✅✅✅✅安装完成✅✅✅✅"