#!/bin/sh

# 在 .gitignore 中添加 `zsh/plugins/` 将 zsh 插件全部不 track
echo "🔄 安装 zsh 插件..."

mkdir -p ~/.zsh/plugins/

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.zsh/plugins/powerlevel10k
git clone --depth=1 https://github.com/zsh-users/zsh-completions.git ~/.zsh/plugins/zsh-completions
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ~/.zsh/plugins/zsh-autosuggestions
# git clone --depth=1 https://github.com/marlonrichert/zsh-autocomplete.git ~/.zsh/plugins/zsh-autocomplete # 2025-05-31 已弃用, 详见 zshrc
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/plugins/zsh-syntax-highlighting

git clone --depth=1 https://github.com/junegunn/fzf-git.sh.git ~/.zsh/plugins/fzf-git.sh

# 安装 zsh-abbr (需要递归克隆子模块)
git clone --recurse-submodules --single-branch --branch main --depth 1 https://github.com/olets/zsh-abbr.git ~/.zsh/plugins/zsh-abbr

# 安装 zsh-autosuggestions-abbreviations-strategy (让 autosuggestions 能建议缩写)
git clone --single-branch --branch main --depth 1 https://github.com/olets/zsh-autosuggestions-abbreviations-strategy.git ~/.zsh/plugins/zsh-autosuggestions-abbreviations-strategy

echo "✅ zsh 插件安装完成"
echo
