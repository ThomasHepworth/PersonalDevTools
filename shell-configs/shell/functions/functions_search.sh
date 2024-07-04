function pygrep() {
    local search_text="$1"
    local directory="${2:-.}"  # Defaults to the current directory if no second arg is provided
    local case_insensitive=""  # Default to case-sensitive search

    # Help message tailored for pygrep
    local help_message="Usage: pygrep [search_text] [directory] [-c]\n\
    -h, --help        Show this help message and exit.\n\
    [search_text]     Specify the text to search within .py files.\n\
    [directory]       Optional. Specify the directory to search in; defaults to the current directory.\n\
    -c                Optional. Perform a case-insensitive search.\n\
    Note: This search excludes any 'venv' directories."

    # Parse command line arguments
    for arg in "$@"; do
        case "$arg" in
            -h|--help)
                echo -e "$help_message"
                return 0
                ;;
            -c)
                case_insensitive="-i"  # Enable case-insensitive search
                ;;
        esac
    done

    # Use grep to search, exclude directories containing 'venv'
    grep --color=always $case_insensitive "$search_text" -r --include="*.py" \
         --exclude-dir='*venv*' "$directory"
}

function search_files() {
    local help_message="Usage: file_search [directory] [pattern] [options]\n\
    Options:\n\
    -h, --help        Show this help message and exit.\n\
    -s, --size        Display the size of each file.\n\
    -x, --exclude     Exclude files matching this pattern.\n\
    -z, --size-range  Filter files by size (e.g., +500k, -10M).\n\
    -m, --modified    Filter files modified since (e.g., '2023-01-01').\n\
    [directory]       Specify the directory to search in; defaults to the current directory.\n\
    [pattern]         Required. Specify the pattern to search for files (e.g., '*.txt')."

    if [[ "$#" -lt 2 ]]; then
        if [[ "$1" == "-h" || "$1" == "--help" ]]; then
            echo -e $help_message
            return 0
        else
            echo "Error: Insufficient arguments provided."
            echo "For help, type: file_search --help"
            return 1
        fi
    fi

    local directory="${1:-.}"  # Default to current directory if not specified
    local pattern="$2"         # Pattern is a required argument
    local exclude_pattern=""   # No exclusion pattern by default
    local size_range=""        # No size range by default
    local modified_since=""    # No modification date filter by default
    local show_size=""         # Do not show file size by default

    shift 2 # Skip the first two arguments (directory and pattern)

    # Parse command line arguments for options
    while [[ "$1" ]]; do
        case "$1" in
            -h|--help)
                echo -e "$help_message"
                return 0
                ;;
            -s|--size)
                show_size="true"
                ;;
            -x=*|--exclude=*)
                exclude_pattern="${1#*=}"
                ;;
            -z=*|--size-range=*)
                size_range="${1#*=}"
                ;;
            -m=*|--modified=*)
                modified_since="${1#*=}"
                ;;
            *)
                echo "Unknown option: $1"
                echo -e "$help_message"
                return 1
                ;;
        esac
        shift  # Move to the next argument
    done

    local find_command="find $directory -name '$pattern' -type f"
    [[ "$exclude_pattern" ]] && find_command+=" ! -name '$exclude_pattern'"
    [[ "$size_range" ]] && find_command+=" -size '$size_range'"
    [[ "$modified_since" ]] && find_command+=" -newermt '$modified_since'"

    if [[ "$show_size" == "true" ]]; then
        find_command+=" -exec ls -lh {} + | awk '{print \$5, \$9}'"
    else
        find_command+=" -exec ls -1 {} +"
    fi

    eval $find_command
}
