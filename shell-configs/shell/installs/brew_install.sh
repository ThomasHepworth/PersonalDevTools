#!/bin/bash

set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if Homebrew is installed
if ! command_exists brew; then
    echo "Error: Homebrew is not installed. Please install Homebrew first."
    exit 1
fi

echo "Updating Homebrew..."
brew update

# List of packages to install or update with descriptions
packages=(
    fzf                # Command-line fuzzy finder for files
    coreutils          # GNU core utilities (more powerful versions of common Unix tools)
    dust               # A more intuitive way to view disk usage in the terminal
    btop               # A modern resource monitor
    midnight-commander # Visual file manager and text editor for the command-line
    cowsay             # Configurable talking cow (for fun terminal messages)
    fortune            # Random quote generator
    zsh-vi-mode        # Vi-mode plugin for Zsh
    uv                 # A pip replacement for Python packages
    atuin              # Enhanced shell history with query/search capabilities
    navi               # An interactive cheatsheet tool for the command-line
    lsd                # A modern alternative to the 'ls' command
    powerlevel10k      # A fast and flexible Zsh theme
    lazygit            # A simple terminal UI for git commands
    adr-tools          # A command-line tool for creating Architecture Decision Records
    aws-vault          # A tool to securely store and access AWS credentials in development environments
    awscli             # The official command-line interface for interacting with AWS services
    fastfetch          # A quick system information fetcher
    zsh-autosuggestions # Fish-like suggestions for Zsh commands
    zsh-syntax-highlighting # Syntax highlighting for Zsh commands
    zoxide             # A smarter 'cd' command for faster navigation
    python@3.9         # Python 3.9 programming language interpreter
    python@3.10        # Python 3.10 programming language interpreter
    python             # Latest version of Python
)

# Install or update each package
for pkg in "${packages[@]}"; do
    if brew ls --versions "$pkg" > /dev/null; then
        echo "Updating $pkg..."
        brew upgrade "$pkg" || echo "Failed to upgrade $pkg. It may be up-to-date or have issues."
    else
        echo "Installing $pkg..."
        brew install "$pkg" || echo "Failed to install $pkg. It may be unavailable or have issues."
    fi
done

echo "All specified packages have been installed or updated!"