#!/bin/sh

# ----- bash to zsh -----
current_shell=$(which "$SHELL")

if echo "$current_shell" | grep -q "zsh"; then
    zsh_version=$(zsh --version | cut -d' ' -f2)
    echo "✅ Current shell is already zsh: $current_shell (version $zsh_version)"
else
    echo "⚠️ Current shell is not zsh. Checking if zsh is available..."

    if which zsh >/dev/null 2>&1; then
        echo "🔄 zsh($(which zsh) version $(zsh --version | cut -d' ' -f2)) is available. Attempting to switch to zsh..."
        sudo chsh -s "$(which zsh)" "$USER"
        echo "🔔 Shell changed. Please log out and log back in for changes to take effect."
    else
        echo "❌ zsh is not installed or not in PATH. Please install zsh first."
        echo "💡 If Brew installed, run `brew install zsh && sudo chsh -s \"$(brew --prefix)/bin/zsh\" \"$USER\"`"
        echo "💡 On Ubuntu, run `sudo apt update && apt-cache policy zsh && sudo apt install zsh -y && sudo chsh -s \"$(which zsh)\" \"$USER\"`"
    fi

    echo "ℹ️ Current shell path is: $current_shell"
fi
