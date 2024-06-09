function setup_python_venv() {
    local VENV_NAME="venv"
    local PYTHON_VERSION="python3"

    # Parse cmd line args
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --python=*)
                PYTHON_VERSION="${1#*=}"
                ;;
            *)
                VENV_NAME="$1"
                ;;
        esac
        shift
    done

    # Check if the specified Python version is available on the machine
    if ! command -v $PYTHON_VERSION &>/dev/null; then
        echo "Specified Python version '$PYTHON_VERSION' is not available on your machine."
        echo "Please install the required version and try again."
        return 1
    fi

    # Check if virtual environment already exists
    if [ ! -d "$VENV_NAME" ]; then
        $PYTHON_VERSION -m venv "$VENV_NAME"
    fi

    source "$VENV_NAME/bin/activate"

    if ! pip install -r requirements.txt; then
        echo "Failed to install requirements. Cleaning up..."
        deactivate
        rm -rf "$VENV_NAME"
        echo "Deleted the virtual environment due to failed setup."
        echo "Check that the version of python you are using is compatible with the requirements."
        echo "You can specify a different version of python using the '--python={version}' flag."
        return 1
    fi

    PY_VERSION=$(python --version)
    echo "Virtual environment '$VENV_NAME' set up and activated for $PY_VERSION."
}
