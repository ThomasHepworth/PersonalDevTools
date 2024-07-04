function execute_hook_script() {
    local script_name="$1"
    local script_path="$HOME/git/hooks/$script_name"

    # Check if the script exists
    if [[ ! -f "$script_path" ]]; then
        echo "Hook script not found: $script_path"
        return 1
    fi

    # src is a custom fn that chmods and executes
    src "$script_path"
}

alias pre_conventional_commit_hook="execute_hook_script pre-receive-conventional-commits.sh"
function setup_git_worktree() {
    local repo_url="$1"
    local branch_name="$2"

    # Display help message if --help is passed
    if [[ "$1" == "--help" ]]; then
        echo "Usage: setup_git_worktree [repository_url] [branch_name]"
        echo " - repository_url: URL of the Git repository to clone"
        echo " - branch_name (optional): Name of the branch for the new worktree"
        echo "If branch_name is not provided, the script will only set up the bare repository."
        return 0
    fi

    # Extract repository name from the URL and add .git
    local bare_repo_dir="./$(basename "$repo_url" .git).git"

    # Check if the repo already exists
    if [[ -d "$bare_repo_dir" ]]; then
        echo "Repository already exists: '$bare_repo_dir'"
        return 1
    fi

    # Clone the repository as a bare repository - bare_repo_dir isn't really necessary atm
    git clone --bare "$repo_url" "$bare_repo_dir"
    if [ $? -ne 0 ]; then
        echo "Failed to clone the repository. Please check the URL and try again."
        return 1
    fi

    echo "----------------------------------------"
    echo "Bare repository created at: $bare_repo_dir"

    if [ -n "$branch_name" ]; then
        # Check if the branch exists on the remote
        if ! git --git-dir="$bare_repo_dir" ls-remote --exit-code --heads origin "$branch_name" &> /dev/null; then
            echo "Branch '$branch_name' does not exist on the remote. Please check the branch name and try again."
            return 1
        fi
        cd $bare_repo_dir
        git worktree add "$branch_name"
        if [ $? -ne 0 ]; then
            echo "Failed to add worktree for branch '$branch_name'. Please check the error message above."
            return 1
        fi
        echo "----------------------------------------"
        echo "Worktree added for branch $branch_name at $worktree_dir"
    fi

    echo "----------------------------------------"
    echo "Repository setup complete."
}

function get_git_url() {
    local open_url=false

    if [[ "$1" == "-o" || "$1" == "--open" ]]; then
        open_url=true
    fi

    # Get the SSH URL
    local ssh_url=$(git remote get-url origin)

    # Check if the URL is an SSH URL
    if [[ $ssh_url == git@github.com:* ]]; then
        # Convert the SSH URL to an HTTPS URL
        https_url=${ssh_url/git@github.com:/https:\/\/github.com\/}
        https_url=${https_url/.git/}
        echo "HTTPS URL: $https_url"
    else
        https_url=$ssh_url
        echo "The remote URL is already an HTTPS URL or not in the expected SSH format."
    fi

    # Open the URL in Google Chrome if the -o flag is provided
    if $open_url; then
        if command -v open &> /dev/null; then
            open -a "Google Chrome" "$https_url"
        else
            echo "Could not detect the web browser to use."
        fi
    fi
}
