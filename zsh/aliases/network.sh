#!/bin/sh

# Ping 公共 DNS 服务器
alias pingg='ping 8.8.8.8'      # Google
alias pingc='ping 1.1.1.1'      # Cloudflare
alias pinga='ping 223.5.5.5'    # 阿里
alias pingt='ping 119.29.29.29' # 腾讯

# 查看本机 IP
# 有代理时是代理 IP, 没有代理时则是本机真实 IP
alias myip='curl cip.cc'

# ---- socks proxy ----
# 需要先安装好 proxychains4
# 并使用 `sudo -E nvim /etc/proxychains.conf` 在最后添加
# socks5  运行socks服务的IP socks服务端口 用户  密码
# 中间使用 tab 或 空格 分割
alias pc='proxychains'

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
