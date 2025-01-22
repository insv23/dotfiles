# >>> conda initialize >>>
# 当前用户使用 root 用户安装的 miniconda
# 但只在特定目录下通过 direnv 激活使用，禁止全局用
# echo 'source ~/.dotfiles/zsh/hosts/minicoda.autodl.zshrc' > .envrc; direnv allow


# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/root/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/root/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/root/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/root/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<