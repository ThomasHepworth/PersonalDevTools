#!/bin/bash

set -e

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Updating Homebrew..."
brew update

# List of packages to install or update
packages=(
    fzf              # Fuzzy find files
    coreutils        # GNU Core Utilities
    dust             # Disk usage viewer
    btop             # Resource monitor
    midnight-commander  # File manager
    cowsay           # Configurable talking cow
    fortune          # Fortune cookie program
    zsh-vi-mode      # Vi mode for Zsh
    glow             # Render markdown files on the terminal
    uv               # A pip replacement
    atuin            # A database of terminal commands
    navi             # An interactive cheatsheet tool for the command-line
)

# Install or update each package
for pkg in "${packages[@]}"; do
    if brew list $pkg &> /dev/null; then
        echo "Updating $pkg..."
        brew upgrade $pkg
    else
        echo "Installing $pkg..."
        brew install $pkg
    fi
done

echo "All specified packages have been installed or updated!"
