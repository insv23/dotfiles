#!/bin/bash
# VS Code 备份：将扩展列表和配置文件同步保存到 dotfiles 仓库

# vscode-backup - Backup VS Code configuration to dotfiles

function vscode-backup () {
    VS_CODE_USER="$HOME/Library/Application Support/Code/User"
    HOSTNAME=$(hostname -s)
    DOTFILES_VS="$HOME/dotfiles-private/VS_Code/$HOSTNAME"

    # Create target directory if it doesn't exist
    mkdir -p "$DOTFILES_VS/snippets"

    # Backup files (force overwrite)
    # alias cp='cp -i'  # -i 参数会交互式确认覆盖
    # \cp 会绕过 alias，直接使用原始的 cp 命令。
    \cp -f "$VS_CODE_USER/settings.json" "$DOTFILES_VS/settings.jsonc"
    \cp -f "$VS_CODE_USER/keybindings.json" "$DOTFILES_VS/keybinds.jsonc"
    \cp -rf "$VS_CODE_USER/snippets/"* "$DOTFILES_VS/snippets/"

    echo "🛫 VS Code configuration backed up to dotfiles-private ($HOSTNAME)"
}