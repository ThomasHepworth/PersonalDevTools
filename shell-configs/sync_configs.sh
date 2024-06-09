#!/bin/zsh

# Store all files under shell-configs
ROOT_DIR="$(dirname $0)"

# Syncs the config files from the local machine to the repository
# ["destination"]="$source"
declare -A paths=(
    [".zshrc"]="$HOME/.zshrc"
    ["p10k/.p10k.zsh"]="$HOME/.p10k.zsh"
    ["wezterm/.wezterm.lua"]="$HOME/.wezterm.lua"
    ["lsdeluxe/"]="$HOME/.config/lsd/"
    ["shell/"]="$HOME/shell/"
)

echo "Starting sync..."
echo "------------------"

# Loop through the associative array
for key in "${(@k)paths}"; do
    src="${paths[$key]}"
    dest="$ROOT_DIR/$key"
    echo "Syncing $src to $dest"

    # Ensure the destination directory exists
    local dir_path=$(dirname "$dest")
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
