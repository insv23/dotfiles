# 手动安装的软件

将 linuxbrew 相关的 env 文件放入 zshenv 后，zshenv 应该没啥坑点了，那依然优先推荐 brew 安装

## [rust/cargo](https://rustup.rs/)
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# zshenv 中已经添加了相关 PATH
# 使用 rezsh 后才生效

# 测试
rustup --version
cargo --version
```

## [node/nvm](https://nodejs.org/en/download)
不推荐使用 `brew install node@22`，因为需要手动加 PATH\
`echo 'export PATH="/home/linuxbrew/.linuxbrew/opt/node@22/bin:$PATH"' >> ~/.zshrc`


1. curl 安装 nvm
2. 将其自动追加到 zshrc 尾部的内容通过 lazygit 丢掉，已经通过在**总的 zshrc**(因为 Neovim 某些插件需要有 nodejs 才能正常运行) 中 `source ~/.dotfiles/zsh/nvm.zshrc` 激活了
3. rezsh
4. nvm install 版本
5. 测试
    ```bash
    which nvm
    which node
    node -v
    npm -v
    ```

## pnpm
一般都是在本地机器上使用，应该都是 mac，所以统一使用 [brew 安装](https://pnpm.io/installation#using-homebrew)\
安装后首先移除自动在 zshrc 中添加的配置，然后在 local.zshrc 中添加下面这个配置块:
```bash
# ===== pnpm configuration =====
# 这个一般都是在本地机器上使用，应该都是 mac，所以统一使用 brew: https://pnpm.io/installation#using-homebrew
# 下面这个 Library 是在 mac 上才有的
# 安装后会自动在 zshrc 中添加下面配置，先手动删除，然后在 local.zshrc 中添加当前块
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
```

## Todo
- bun 与 pnpm (配置文件参考 mba.loca)

# brew 已经安装了，但如果要手动安装可以参考

## [uv](https://docs.astral.sh/uv/getting-started/installation/) 
(brew-both.txt 已经添加 uv，无需手动安装)
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh

# 位于 `~/.local/bin`, zshenv 文件已经添加该路径
```


