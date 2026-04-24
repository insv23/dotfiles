# dotfiles

[简体中文](README.md)

My dotfiles configuration, focused on providing a clean, maintainable, and cross-platform development environment.

## Features

- 🚀 One-click installation powered by [Dotbot](https://github.com/anishathalye/dotbot)
- 🖥️ Smart configuration management based on hostname
- 🔧 Complete terminal development environment:
  - 💻 Beautiful and efficient shell with zsh + [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
  - 📝 Smart command history search and sync with [atuin](https://github.com/atuinsh/atuin)
  - 🔄 Automated environment variable management via [direnv](https://github.com/direnv/direnv)
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

   If some files already exist, remove them first:

   ```zsh
   rm -f ~/.profile ~/.bashrc ~/.gitconfig ~/.zshrc && ./install
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
├── bash/           # Bash config (bashrc, profile, inputrc)
├── brew/           # Homebrew install scripts and app lists
├── claude/         # Claude Code config (agents, commands, settings)
├── git/            # Git config (gitconfig, gitignore_global)
├── hammerspoon/    # Hammerspoon automation config
├── karabiner/      # Karabiner key remapping config
├── kitty/          # Kitty terminal config
├── lazygit/        # Lazygit config
├── tmux/           # Tmux config and plugins
├── vim/            # Vim config and plugins
├── yazi/           # Yazi file manager config
├── zellij/         # Zellij terminal multiplexer config
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

- If your machine has global proxy enabled by default but you want to automatically disable it for certain project directories, you can use direnv:

  1. Create a `.envrc` file in the directory:

  ```bash
  source_env ~/.dotfiles/zsh/aliases.sh
  pxyoff
  ```

  2. Allow direnv to load the configuration:

  ```bash
  direnv allow
  ```

  This will automatically disable the proxy when entering the directory and restore the global proxy settings when leaving.

## Common Issues

### Homebrew Installation Fails

- Ensure you're not running as root
- Check if your system architecture is supported
- Verify network connectivity

### File Linking Errors

- Check if files already exist at target locations
- Use `rm -f` to remove existing files
- Run `./install` again

## Contributing

Issues and Pull Requests are welcome!

## Acknowledgments

- [Dotbot](https://github.com/anishathalye/dotbot)
- [Homebrew](https://brew.sh/)
- And all the excellent open-source tools
