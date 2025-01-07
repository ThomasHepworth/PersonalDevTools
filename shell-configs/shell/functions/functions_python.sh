sact() {
    if [ -n "$1" ]; then
        venvs_to_try=("$1")
    else
        venvs_to_try=("venv" ".venv")
    fi

    for venv in "${venvs_to_try[@]}"; do
        if [ -d "$venv" ]; then
            echo "Activating '$venv'..."
            source "$venv/bin/activate"
            return 0
        fi
    done

    echo "Error: No virtual environment found ('$(IFS=', '; echo "${venvs_to_try[*]}")')."
    return 1
}