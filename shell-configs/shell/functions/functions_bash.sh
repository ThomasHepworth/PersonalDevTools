# Extract a zipped file
ex () {
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

# pygrep "search_text" "directory" - directory is optional
function pygrep() {
    local search_text=$1
    local directory=${2:-.}  # Defaults to current directory if no second argument is provided
    grep --color=always "$search_text" -r --include="*.py" "$directory"
}

function src() {
    if [[ -f "$1" ]]; then  # Check if the file exists
        chmod +x "$1"       # Make the file executable
        ./"$1"              # Execute the file
    else
        echo "Error: '$1' is not a valid file."
    fi
}
