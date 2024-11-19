# cd folder
alias ..='cd ..'
alias ...='cd ../..'

# Use colors in coreutils utilities output
alias grep='grep --color'

# ---- Eza (better ls) -----
alias ls="eza --color=always --long --no-filesize --icons=always --no-time --no-user --no-permissions"
alias ll="eza --color=always --long --git --icons=always"
alias lla="eza --color=always --long --git --icons=always -a"

# Aliases to protect against overwriting
alias cp='cp -i'
alias mv='mv -i'

# git related aliases
# in `../gitconfig`
alias gag='git exec ag'
alias ginsv='git config user.name "insv";git config user.email "insv23@outlook.com"'
# cd to git root directory
alias cdgr='cd "$(git root)"'
# create .gitignore template
function gi() { curl -sLw "\n" https://www.toptal.com/developers/gitignore/api/$@; }

# zshrc
alias szsh='source ~/.zshrc'

# Homebrew
alias brs='brew search'
alias bri='brew install'
alias bric='brew install --cask'
alias bro='brew info'
alias bru='brew uninstall'

# nvim
alias nv='nvim'

# Update dotfiles
dfu() {
  (
    cd ~/.dotfiles && git pull --ff-only && ./install -q
  )
}

# python
alias py='python'
alias pym='python -m'

# python venv
alias pymv='python -m venv venv'
alias pymva='source venv/bin/activate'
alias pymvd='deactivate'

# pyenv-virtualenv
alias pyve='pyenv virtualenv'
alias pyvels='pyenv virtualenvs'
alias pyveon='pyenv activate'
alias pyveoff='pyenv deactivate'
alias pyverm='pyenv virtualenv-delete'

# Create a directory and cd into it
mkcd() {
  if [ ! -n "$1" ]; then
    echo "Enter a directory name"
  elif [ -d $1 ]; then
    echo "'$1' already exists"
  else
    mkdir -pv $1 && cd $1
  fi
}

# proxy
# Mac, WSL, Linux
if uname -a | grep -q "Darwin"; then
  # if (($(uname) == Darwin)); then // Not Work on Linux: https://blog.insv.xyz/shell-str-compare
  export pxy_ip=127.0.0.1
  export pxy_http_port=7890
  export pxy_all_port=7890
# elif (($(cat /proc/version | grep -c "WSL") == 1)); then
elif cat /proc/version | grep -q "WSL"; then
  export pxy_ip=$(cat /etc/resolv.conf | grep "nameserver" | cut -f 2 -d " ")
  export pxy_http_port=7890
  export pxy_all_port=7890
else
  # Linux: v2ray
  export pxy_http_port=20171
  export pxy_all_port=20170
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

# Tmux
alias tmat='tmux at -t'
alias tmnew='tmux new -s'
alias tmkt='tmux kill-session -t'
