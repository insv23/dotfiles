#!/bin/zsh

# Get current platform
if uname -a | grep -q "Darwin"; then
	if command -v brew &> /dev/null; then
    echo "Homebrew is installed"
  else
    echo "Homebrew is not installed, installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "Homebrew is installed successfully"
  fi
fi