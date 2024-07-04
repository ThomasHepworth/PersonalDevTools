# Unzip a zipped file
function unzip () {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz1)   tar xvjf $1                  ;;
            *.tar.gz)    tar xvzf $1                  ;;
            *.bz2)       bunzip2 $1                   ;;
            *.rar)       unrar x $1                   ;;
            *.gz)        gunzip $1                    ;;
            *.tar)       tar xvf $1                   ;;
            *.tbz2)      tar xvjf $1                  ;;
            *.tgz)       tar xvzf $1                  ;;
            *.zip)       unzip $1                     ;;
            *.Z)         uncompress $1                ;;
            *.7z)        7z x $1                      ;;
            *)           echo "can't extract '$1'..." ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}


function brew() {
  if [[ $1 == "add" ]]; then
    # Remove the first argument ("add")
    shift
    # Install the package
    command brew install "$@"
    # Update the global Brewfile
    command brew bundle dump --global --force
  else
    # Call the original brew command with all original arguments
    command brew "$@"
  fi
}

function brew_u() {
  # Update Homebrew
  brew update
  # Upgrade all installed formulae
  brew upgrade
  # Remove outdated versions from the cellar
  brew cleanup
}

function src() {
    local filename="$1"

    # Help message
    local help_message="Usage: src [-h|--help] <script.sh>\n\
    <script.sh>\tSpecify the shell script (.sh) to execute. The script must be executable and have a .sh extension."

    # Check for help option or no input
    if [[ "$filename" == "-h" || "$filename" == "--help" || -z "$filename" ]]; then
        echo -e "$help_message"
        return 0
    fi

    # Check if the file is a valid shell script with a .sh extension
    if [[ -f "$filename" && "$filename" == *.sh ]]; then
        chmod u+x "$filename"   # Make the file executable

        echo "Executing $filename..."
        ./"$filename"   # Execute the file using bash
    elif [[ -f "$filename" ]]; then
        echo "Error: '$filename' is not a .sh script."
        return 1  # Return a non-zero status to indicate failure
    else
        echo "Error: '$filename' does not exist."
        return 1  # Return a non-zero status to indicate failure
    fi
}
