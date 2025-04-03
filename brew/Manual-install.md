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

```bash
1. curl 安装 nvm
2. rezsh
3. nvm install 版本
4. 测试
node -v
npm -v
```

# brew 已经安装了，但如果要手动安装可以参考

## [uv](https://docs.astral.sh/uv/getting-started/installation/) 
(brew-both.txt 已经添加 uv，无需手动安装)
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh

# 位于 `~/.local/bin`, zshenv 文件已经添加该路径
```


