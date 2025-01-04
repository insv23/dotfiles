#!/bin/sh

# Ping 公共 DNS 服务器
alias pingg='ping 8.8.8.8'         # Google
alias pingc='ping 1.1.1.1'         # Cloudflare
alias pinga='ping 223.5.5.5'       # 阿里
alias pingt='ping 119.29.29.29'    # 腾讯

# 查看本机 IP
# 有代理时是代理 IP, 没有代理时则是本机真实 IP
alias ip='curl ipinfo.io'

# ---- proxy ----
# macOS, WSL 使用 Clash/Mihomo Party
# Linux 使用 v2ray
if uname -a | grep -q "Darwin"; then
  # macOS
  export pxy_ip=127.0.0.1
  export pxy_http_port=7890
  export pxy_all_port=7890
elif cat /proc/version | grep -q "WSL"; then
  # WSL
  if [ -f /etc/resolv.conf ]; then
    pxy_ip=$(cat /etc/resolv.conf | grep "nameserver" | cut -f 2 -d " " | head -n 1)
    if [ -z "$pxy_ip" ]; then
        echo -e "\033[31m[×] Error: Failed to get nameserver IP from /etc/resolv.conf \033[0m"
        return 1
    fi
    export pxy_ip=$pxy_ip
    export pxy_http_port=7890
    export pxy_all_port=7890

  else
    echo -e "\033[31m[×] Error: /etc/resolv.conf not found \033[0m"
    return 1
  fi

else
  # Linux
  export pxy_http_port=20171
  export pxy_all_port=20170
fi


pxyoff() {
  unset http_proxy
  unset https_proxy
  unset all_proxy
  echo -e "\033[31m[×] Proxy Off\033[0m"
}

pxyon() {
  export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
  export http_proxy="http://$pxy_ip:$pxy_http_port"
  export https_proxy="http://$pxy_ip:$pxy_http_port"
  export all_proxy="socks5://$pxy_ip:$pxy_all_port"
  echo -e "\033[32m[√] Proxy On $pxy_ip:$pxy_http_port/$pxy_all_port\033[0m"
}
