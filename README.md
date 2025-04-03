# dotfiles

我的 dotfiles 配置，专注于提供一个简洁、可维护且跨平台的开发环境。

## 特点

- 🚀 基于 [Dotbot](https://github.com/anishathalye/dotbot) 的一键安装
- 🖥️ 基于主机名的智能配置管理
- 🔧 完整的终端开发环境：
  - 💻 使用 zsh + [Powerlevel10k](https://github.com/romkatv/powerlevel10k) 打造美观高效的 shell
  - 📝 集成 [atuin](https://github.com/atuinsh/atuin) 实现智能命令历史搜索与同步
  - 🔄 通过 [direnv](https://github.com/direnv/direnv) 实现自动化环境变量管理
  - 📂 搭配 [yazi](https://github.com/sxyazi/yazi) 提供现代化文件管理体验
  - 🌳 使用 [lazygit](https://github.com/jesseduffield/lazygit) 实现优雅的 Git 操作
  - ⚡ 基于 [lazyvim](https://github.com/LazyVim/LazyVim) 的强大 Neovim 配置
- 🔌 告别 submodules 依赖地狱，zsh/tmux/vim 插件管理简单直观
- 🍺 Linux(x86) 采用 [Homebrew](https://brew.sh/)，享受与 macOS 一致的包管理体验
- 🌐 开箱即用的智能代理配置（完美支持 macOS/WSL/Linux）
- ⚙️ 现代化终端工具链集成（eza/bat/delta/yazi 等）

## 安装指南

### 前置条件

- 🚫 注意: ARM 架构的 Linux 暂不支持 Homebrew

- ⛑️ 需要预先安装 git, zsh, python 和 gcc

  ```bash
  # Ubuntu 示例
  sudo apt update && sudo apt install git zsh python3 build-essential -y
  ```

- ⚠️ Linux 下不能以 root 用户安装 Homebrew

  ```bash
  # 如需要可以创建新用户( 需保证已经安装了 zsh)
  NEW_USER_NAME=alex
  sudo useradd -m -s /bin/zsh -G users,sudo $NEW_USER_NAME && sudo passwd $NEW_USER_NAME
  ```

  切换到新用户 `alex`
  ```bash
  su - alex
  ```

### 快速开始

1. 克隆仓库

   ```bash
   git clone https://github.com/insv23/dotfiles.git ~/.dotfiles && cd ~/.dotfiles
   ```

2. 运行安装脚本

   如果某些文件已存在，需要先删除:

   ```bash
   rm -f ~/.profile ~/.bashrc ~/.gitconfig ~/.zshrc && ./install
   source ~/.zshrc
   ```

   ```bash
   ./zsh/install_plugins.sh
   ./vim/install_plugins.sh
   ./brew/0.install.sh
   ./brew/1.brewInstallApps.sh
   (⬇️ Ubuntu 系统交互式安装 Caddy/Docker 等)
   sudo ./brew/2.ubuntuInstall.sh
   ./tmux/install_tpm.sh (deprecated, 使用 zellij 替代)
   ```

   运行完成后，注销当前用户会话并重新登录，配置将自动生效。
  
3. 部分需要手动安装的，参考[手动安装指南](./brew/Manual-install.md)


4. 主机特定配置
   系统会根据当前主机名自动创建对应的配置文件，例如：`~/.dotfiles/zsh/hosts/macmini.local.zshrc`
   你可以在这个文件中添加仅适用于当前主机的个性化配置，比如：
   - 代理设置
   - 环境变量
   - 本地工具路径
   - 特定别名(alias)等

### 将远程仓库同步到本地

在**任意目录**下执行:

```bash
dfu
```

将会以远程仓库的最新状态覆盖本地 dotfiles 仓库

## 配置说明

### 目录结构

```
.
├── brew/           # Homebrew 相关配置
├── kitty/          # kitty 终端配置
├── nvim/           # Neovim 配置
├── tmux/           # Tmux 配置
├── vim/            # Vim 配置
├── yazi/           # Yazi 文件管理器配置
└── zsh/            # Zsh 配置
    └── hosts/      # 不同主机的特定配置
```

### 主要功能

#### 包管理

- 使用 Homebrew 作为主要的包管理器
- 预配置了常用开发工具

#### 终端增强

- 现代化的命令行替代品
  - `ls` → `eza`
  - `cat` → `bat`
  - `cd` → `zoxide`
  - `find` → `fd`
- Git 集成
  - 美化的差异查看器 (delta)
  - 快捷命令别名
  - 自动补全

#### 智能代理

- 自动检测运行环境
- 简单的开关命令
  - `pxyon` - 启用代理
  - `pxyoff` - 关闭代理
- 如果想让某台机器的终端启动时自动开启代理，可以按以下步骤设置：

  1. 找到对应的主机配置文件：`zsh/hosts/主机名.local.zshrc`
  2. 在文件末尾添加：

  ```bash
  # ---- auto proxy ----
  pxyon > /dev/null
  ```

- 如果你的机器默认开启了全局代理，但想让某些项目目录自动关闭代理，可以使用 direnv.

  1. 在该目录下创建 `.envrc` 文件:

  ```bash
  source_env ~/.dotfiles/zsh/aliases.sh
  pxyoff
  ```

  2. 允许 direnv 加载该配置:

  ```bash
  direnv allow
  ```

  这样每次进入该目录时会自动关闭代理，离开时则恢复全局代理设置。

## 常见问题

### Homebrew 安装失败

- 确保不是以 root 用户运行
- 检查系统架构是否支持
- 确保网络连接正常

### 文件链接错误

- 检查目标位置是否有同名文件
- 使用 `rm -f` 删除已存在的文件
- 重新运行 `./install`

## 贡献

欢迎提交 Issue 和 Pull Request！

## 致谢

- [Dotbot](https://github.com/anishathalye/dotbot)
- [Homebrew](https://brew.sh/)
- 以及所有优秀的开源工具

## 许可

MIT License
