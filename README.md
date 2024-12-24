# dotfiles

[简体中文](README.zh-CN.md)

My dotfiles configuration, focused on providing a clean, maintainable, and cross-platform development environment.

## Features

- 🖥️ Smart configuration management based on hostname
- 🔌 No submodules dependency hell, simple and intuitive plugin management
- 🍺 Homebrew on Linux(x86) for consistent package management experience with macOS
- 🌐 Out-of-the-box smart proxy configuration (supports macOS/WSL/Linux)
- ⚡ Modern terminal toolchain (eza/bat/delta/yazi etc.)
- 🚀 One-click installation with Dotbot
- 📝 Comprehensive documentation and comments

## Installation Guide

### Prerequisites

- 🚫 Note: Homebrew is not supported on ARM Linux

- ⛑️ Git and zsh must be pre-installed

  ```bash
  # Ubuntu example
  sudo apt update && sudo apt install git zsh -y
  ```

- ⚠️ Homebrew cannot be installed as root on Linux

  ```bash
  # Create a new user if needed
  NEW_USER_NAME=alex
  sudo useradd -m -s /bin/bash -G users,sudo $NEW_USER_NAME && sudo passwd $NEW_USER_NAME
  ```

### Quick Start

1. Clone the repository

```bash
git clone https://github.com/your-username/dotfiles.git ~/.dotfiles && cd ~/.dotfiles
```

2. Run the installation script

```bash
./install
```

If some files already exist, remove them first:

```bash
rm -f ~/.profile ~/.bashrc ~/.gitconfig && ./install
```

### Sync Remote Repository to Local

Execute from **any directory**:

```bash
dfu
```

This will overwrite the local repository with the latest state from the remote repository.

## Configuration Details

### Directory Structure

```
.
├── brew/           # Homebrew related configuration
├── kitty/          # Kitty terminal configuration
├── nvim/           # Neovim configuration
├── tmux/           # Tmux configuration
├── vim/            # Vim configuration
├── yazi/           # Yazi file manager configuration
└── zsh/            # Zsh configuration
    └── hosts/      # Host-specific configurations
```

### Main Features

#### Package Management

- Uses Homebrew as the primary package manager
- Pre-configured with common development tools

#### Terminal Enhancements

- Modern command-line alternatives
  - `ls` → `eza`
  - `cat` → `bat`
  - `cd` → `zoxide`
  - `find` → `fd`
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
