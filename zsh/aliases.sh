# Use colors in coreutils utilities output
alias ls='ls --color=auto'
alias grep='grep --color'

# ls aliases
alias ll='ls -lah'
alias la='ls -A'
alias l='ls'

# Aliases to protect against overwriting
alias cp='cp -i'
alias mv='mv -i'

# git related aliases
alias gag='git exec ag'

# Update dotfiles
dfu() {
    (
        cd ~/.dotfiles && git pull --ff-only && ./install -q
    )
}

# cd to git root directory
alias cdgr='cd "$(git root)"'

# Create a directory and cd into it
mkcd() {
  if [ ! -n "$1" ]; then
    echo "Enter a directory name"
  elif [ -d $1 ]; then
    echo "\`$1' already exists"
  else
    mkdir -pv $1 && cd $1
  fi
}

# proxy 
# Mac, WSL, Linux
if (($(uname | grep -c "Darwin") == 1)); then
    export pxy_ip=127.0.0.1
    export pxy_http_port=6152
    export pxy_all_port=6153
elif (($(cat /proc/version | grep -c "WSL") == 1 )); then
    export pxy_ip=$(cat /etc/resolv.conf | grep "nameserver" | cut -f 2 -d " ")
    export pxy_http_port=7890
    export pxy_all_port=7890
else
    export pxy_ip=127.0.0.1
    export pxy_http_port=7890
    export pxy_all_port=7890
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

# docker
alias dkd='docker compose down'
alias dku='docker compose up'
alias dkud='docker compose up -d'
alias caddy_reload='z caddy;docker compose exec -w /etc/caddy caddy caddy reload'
function dkspp() {
  id=$(docker ps -a | grep $1 | awk '{print $1}')
  docker stop $id
  docker container prune
}