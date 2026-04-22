#!/bin/sh

# 在 .gitignore 中添加 `zsh/plugins/` 将 zsh 插件全部不 track
echo "🔄 安装 zsh 插件..."

mkdir -p ~/.zsh/plugins/

# 高性能 zsh 主题，支持 git 状态、执行时间、vi 模式等丰富提示符信息
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.zsh/plugins/powerlevel10k

# 补全规则集合，为数百个命令提供额外的 Tab 补全定义
git clone --depth=1 https://github.com/zsh-users/zsh-completions.git ~/.zsh/plugins/zsh-completions

# 根据历史命令在光标后灰色显示建议，按右方向键接受整行，Alt-F 逐词接受
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ~/.zsh/plugins/zsh-autosuggestions

# 2025-05-31 已弃用，详见 zshrc
# git clone --depth=1 https://github.com/marlonrichert/zsh-autocomplete.git ~/.zsh/plugins/zsh-autocomplete

# 实时高亮命令行，可执行命令显示绿色，不存在的命令显示红色
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/plugins/zsh-syntax-highlighting

# 提供 Ctrl-G 系列快捷键，用 fzf 模糊选择 git 对象（分支、commit、tag、stash 等）并插入命令行
git clone --depth=1 https://github.com/junegunn/fzf-git.sh.git ~/.zsh/plugins/fzf-git.sh

# 类似 fish shell 的缩写管理工具，输入缩写后自动展开为完整命令（需要递归克隆子模块）
git clone --recurse-submodules --single-branch --branch main --depth 1 https://github.com/olets/zsh-abbr.git ~/.zsh/plugins/zsh-abbr

# 让 zsh-autosuggestions 能够识别并建议 zsh-abbr 定义的缩写（必须在两者之后加载）
git clone --single-branch --branch main --depth 1 https://github.com/olets/zsh-autosuggestions-abbreviations-strategy.git ~/.zsh/plugins/zsh-autosuggestions-abbreviations-strategy

# 接管 zsh 原生 Tab 补全菜单，将所有补全候选（命令、分支、文件等）通过 fzf 展示
# 必须在 compinit 之后、zsh-autosuggestions 之前加载
git clone --depth=1 https://github.com/Aloxaf/fzf-tab.git ~/.zsh/plugins/fzf-tab

echo "✅ zsh 插件安装完成"
echo
