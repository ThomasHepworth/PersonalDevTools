#!/bin/zsh

set -e

# Store all files under shell-configs
ROOT_DIR="$(dirname $0)"

# Set HOME to its value if set, or to ~ if not
HOME="${HOME:-~}"

# Syncs the config files based on the provided option
# "destination" "source"
declare -A paths
paths=(
    ".zshrc" "$HOME/.zshrc"
    "p10k/.p10k.zsh" "$HOME/.p10k.zsh"
    "wezterm/.wezterm.lua" "$HOME/.wezterm.lua"
    "lsdeluxe/" "$HOME/.config/lsd/"
    "shell/" "$HOME/shell/"
    "git/" "$HOME/git/"
)

# Check for required argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 [copy_to_repo | copy_to_local]"
    exit 1
fi

# Select operation based on argument
operation="$1"

echo "Starting sync operation: $operation"
echo "-----------------------------------"

# Perform the sync based on the selected operation
for key in "${(@k)paths}"; do

    if [ "$operation" = "copy_to_repo" ]; then
        src="${paths[$key]}"
        dest="$ROOT_DIR/$key"
    elif [ "$operation" = "copy_to_local" ]; then
        src="$ROOT_DIR/$key"
        dest="${paths[$key]}"
    fi

    echo "Syncing $src to $dest"

    # Ensure the destination directory exists
    dir_path=$(dirname "$dest")
    if [ ! -d "$dir_path" ]; then
        mkdir -p "$dir_path"
    fi

    if [ -d "$src" ]; then
        rsync -a "$src/" "$dest/"
    elif [ -f "$src" ]; then
        rsync -a "$src" "$dest"
    else
        echo "Warning: Source not found or not valid: $src"
    fi

done
