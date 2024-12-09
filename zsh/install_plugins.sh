#!/bin/sh

# 在 .ignore 中添加 `zsh/plugins/` 将 zsh 插件全部不 track
mkdir -p ~/.zsh/plugins/

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.zsh/plugins/powerlevel10k
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ~/.zsh/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/marlonrichert/zsh-autocomplete.git ~/.zsh/plugins/zsh-autocomplete
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/plugins/zsh-syntax-highlighting

git clone --depth=1 https://github.com/junegunn/fzf-git.sh.git ~/.zsh/plugins/fzf-git.sh
