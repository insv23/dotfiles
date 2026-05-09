# >>> conda initialize >>>
# 当前用户使用 root 用户安装的 miniconda
# 按需在 shell 中手动 source，禁止全局用:
# source ~/.dotfiles/zsh/hosts/minicoda.autodl.zshrc
# 创建虚拟环境:
# conda create -n <环境名称> python=<Python版本>
# 激活虚拟环境:
# conda activate <环境名称>


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
