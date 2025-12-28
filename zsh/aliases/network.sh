#!/bin/sh

# ---- proxy ----
# macOS, WSL 使用 Clash/Mihomo Party
# Linux 使用 v2ray

pxyon() {
  export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
  if uname -a | grep -q "Darwin"; then
    export http_proxy="http://127.0.0.1:7890"
    export https_proxy="http://127.0.0.1:7890"
    export all_proxy="http://127.0.0.1:7890"
    echo -e "\033[32m[√] Proxy On 127.0.0.1:7890\033[0m"
  elif cat /proc/version | grep -q "WSL"; then
    if [ -f /etc/resolv.conf ]; then
      pxy_ip=$(cat /etc/resolv.conf | grep "nameserver" | cut -f 2 -d " " | head -n 1)
      export http_proxy="http://$pxy_ip:7890"
      export https_proxy="http://$pxy_ip:7890"
      export all_proxy="http://$pxy_ip:7890"
      echo -e "\033[32m[√] Proxy On $pxy_ip:7890\033[0m"
    else
      echo -e "\033[31m[×] Error: /etc/resolv.conf not found \033[0m"
      return 1
    fi
  else
    export http_proxy="http://127.0.0.1:20171"
    export https_proxy="http://127.0.0.1:20171"
    export all_proxy="socks5://127.0.0.1:20170"
    echo -e "\033[32m[√] Proxy On 127.0.0.1:20171/20170\033[0m"
  fi
}

pxyoff() {
  unset http_proxy
  unset https_proxy
  unset all_proxy
  echo -e "\033[31m[×] Proxy Off\033[0m"
}

# 使用自己设定的 socks 代理
# 在用户家目录下添加 .socks 文件用来保存 socks 配置，其中只有一行:
# socks5://用户名:密码@IP:socks端口
pxyss() {
  if [ ! -f ~/.socks ]; then
    echo "Error: ~/.socks file not found."
    return 1
  fi
  local proxy_server=$(cat ~/.socks)
  export http_proxy="$proxy_server"
  export https_proxy="$proxy_server"
  export all_proxy="$proxy_server"
  echo -e "\033[32m[√] Proxy On socks5\033[0m"
}

# 使用自己设定的 http 代理
# 在用户家目录下添加 .http 文件用来保存 http 配置，其中只有一行:
# http://用户名:密码@IP:http端口
pxyhp() {
  if [ ! -f ~/.http ]; then
    echo "Error: ~/.http file not found."
    return 1
  fi
  local proxy_server=$(cat ~/.http)
  export http_proxy="$proxy_server"
  export https_proxy="$proxy_server"
  export all_proxy="$proxy_server"
  echo -e "\033[32m[√] Proxy On http\033[0m"
}
