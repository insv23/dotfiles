# dotfiles

[简体中文](README.md)

My dotfiles configuration, focused on providing a clean, maintainable, and cross-platform development environment.

## Features

- 📦 One-click installation powered by [dotdrop](https://github.com/deadc0de6/dotdrop): deployed as symlinks by default, so the repo file and the deployed path are one file and edits take effect immediately; a program that refuses symlinks can be deployed as a standalone copy with `link: nolink`
- 🖥️ Smart configuration management based on hostname
- 🔧 Complete terminal development environment:
  - 💻 Beautiful and efficient shell with zsh + [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
  - 📝 Smart command history search and sync with [atuin](https://github.com/atuinsh/atuin)
  - 📂 Modern file management experience with [yazi](https://github.com/sxyazi/yazi)
  - 🌳 Elegant Git operations through [lazygit](https://github.com/jesseduffield/lazygit)
- 🔌 Simple and intuitive zsh/tmux plugin management without submodule overhead
- 🍺 Consistent package management experience with [Homebrew](https://brew.sh/) on Linux(x86) and macOS
- 🌐 Out-of-the-box smart proxy configuration (perfect support for macOS/WSL/Linux)
- ⚙️ Modern terminal toolchain integration (eza/bat/delta/yazi and more)

## Installation Guide

### Prerequisites

- 🚫 Note: Homebrew is not supported on ARM Linux

- ⛑️ Git, zsh, python and gcc must be pre-installed

  ```bash
  # Ubuntu example
  sudo apt update && sudo apt install git zsh python3 build-essential -y
  ```

- ⚠️ Homebrew cannot be installed as root on Linux

  ```bash
  # Create a new user if needed (zsh must be pre-installed)
  NEW_USER_NAME=alex
  sudo useradd -m -s /bin/zsh -G users,sudo $NEW_USER_NAME && sudo passwd $NEW_USER_NAME
  ```

  Switch to the new user:
  ```bash
  su - alex
  ```

### Quick Start

1. Clone the repository

   ```bash
   git clone https://github.com/insv23/dotfiles.git ~/.dotfiles && cd ~/.dotfiles
   ```

2. Run the installation script

   Install dotdrop first:

   ```zsh
   brew install dotdrop    # on Linux use pipx install dotdrop
   ```

   Then run `./install`. Existing files at the target locations are backed up to `.dotdropbak` before being replaced, so manual cleanup is no longer needed:

   ```zsh
   ./install
   source ~/.zshrc
   ```

   Use the interactive wizard to install plugins and tools:

   ```zsh
   ./setup.zsh
   ```

   Ubuntu users additionally run (interactive install of Caddy/Docker etc.):

   ```zsh
   sudo ./brew/2.ubuntuInstall.sh
   ```

   After installation, log out of your current user session and log back in for the configuration to take effect automatically.

3. For software that requires manual installation, refer to the [Manual Installation Guide](./brew/Manual-install.md).

4. Host-specific Configuration

   The system will automatically create a configuration file based on your hostname, for example: `~/.dotfiles/zsh/hosts/macmini.local.zshrc`

   You can add host-specific customizations in this file, such as:

   - Proxy settings
   - Environment variables
   - Local tool paths
   - Custom aliases

### Sync Remote Repository to Local

Execute from **any directory**:

```bash
dfu
```

This fast-forward syncs the latest remote changes to your local repo (uses `git pull --ff-only`).

## Configuration Details

### Directory Structure

```
.
├── atuin/          # Atuin shell history config
├── agents/         # Shared instructions for Claude, Codex, and Pi
├── bash/           # Bash config (bashrc, profile, inputrc)
├── brew/           # Homebrew install scripts and app lists
├── git/            # Git config (gitconfig, gitignore_global)
├── config.yaml     # dotdrop mapping table
├── hammerspoon/    # Hammerspoon automation config
├── herdr/          # Herdr config and status scripts
├── hunk/           # Hunk config
├── karabiner/      # Karabiner key remapping config
├── kitty/          # Kitty terminal config
├── lazygit/        # Lazygit config
├── vim/            # Vim config and plugins
├── yazi/           # Yazi file manager config
└── zsh/            # Zsh config, plugins, aliases
    └── hosts/      # Per-host configuration files
```

### Main Features

#### Package Management

- Uses Homebrew as the primary package manager
- Pre-configured with common development tools

#### Terminal Enhancements

- Modern CLI tools available
  - `eza`: enhanced file listing (via `ll` and `lls` aliases)
  - `bat`: syntax-highlighted file viewer (used in fzf previews)
  - `zoxide`: smarter directory jumping (via the `z` command)
  - `fd`: faster file search, `delta`: better diff output
- Git integration
  - Beautiful diff viewer (delta)
  - Command aliases
  - Auto-completion

#### Smart Proxy

- Automatic environment detection
- Simple toggle commands
  - `pxyon` - Enable proxy
  - `pxyoff` - Disable proxy
- To automatically enable proxy on terminal startup for a specific machine:

  1. Find the corresponding host configuration file: `zsh/hosts/hostname.local.zshrc`
  2. Add at the end of the file:

  ```bash
  # ---- auto proxy ----
  pxyon > /dev/null
  ```


## Common Issues

### Homebrew Installation Fails

- Ensure you're not running as root
- Check if your system architecture is supported
- Verify network connectivity

### File Linking Errors

- Run `dotdrop -c config.yaml compare` to inspect src/dst differences
- When a file already exists, `backup: true` keeps a `.dotdropbak` copy before overwriting
- Re-run `./install` once fixed

## Contributing

Issues and Pull Requests are welcome!

## Acknowledgments

- [dotdrop](https://github.com/deadc0de6/dotdrop)
- [Homebrew](https://brew.sh/)
- And all the excellent open-source tools
