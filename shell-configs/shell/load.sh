#!/bin/bash

# Shell directory notes:
# 1) load.sh should live in the 'shell' directory
# 2) 'functions' and 'aliases' should have their own
# directories, but still live in the 'shell' directory.


# Function to list contents of a script file based on type (aliases or functions)
function display_script_definitions() {
    local script_file="$1"
    local content_type="$2"  # either 'aliases' or 'functions'

    if [[ "$content_type" == "aliases" ]]; then
        echo "Aliases defined in $script_file:"
        grep '^alias' "$script_file"
    elif [[ "$content_type" == "functions" ]]; then
        echo "Functions defined in $script_file:"
        grep '^function ' "$script_file" | awk '{print $2}' | cut -d '(' -f 1 ;
    else
        echo "Invalid content type specified. Please choose 'aliases' or 'functions'."
    fi
}

source_and_alias_scripts() {
    for script in "$folder_path"/*.sh; do
        source "$script"
        # Extract script name and folder name - these are used to create the print alias
        script_name=$(basename "${script}" .sh)
        folder_name=${folder_path##*/}
        # Create an alias to print all functions or aliases in the script
        alias "$script_name"="display_script_definitions '$script' '$folder_name'"
    done
}

# Function to load scripts and create aliases
initialise_script_directories() {
    local shell_folder_path="$1"

    folders_to_load=("functions" "aliases")

    for folder in $folders_to_load; do
        local folder_path="$shell_folder_path/$folder"

        if [ -d $folder_path ]; then
            source_and_alias_scripts "$folder_path"
        fi
    done
}

# initialise_script_directories $shell_folder
local shell_folder=$(dirname "${(%):-%x}")
initialise_script_directories "$HOME/shell"
