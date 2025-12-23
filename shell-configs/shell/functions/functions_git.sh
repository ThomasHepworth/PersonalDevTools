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

# git_worktree_setup <ssh-url> [-d <anchor-dir>] [-b <branch>] [-p <worktree-path>] [-r <remote>] [--no-track]
# Creates a bare anchor repo (default: $PWD/<repo>.git) and a first worktree for <branch>.
function git_worktree_setup() {
    local ssh_url anchor_dir branch worktree_path remote track
    ssh_url="$1"; shift || true
    anchor_dir=""        # default derived from CWD
    branch=""            # default = remote HEAD branch
    worktree_path=""     # default ../<repo>__<branch>
    remote="origin"
    track="true"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--dir)       anchor_dir="$2"; shift 2 ;;
            -b|--branch)    branch="$2"; shift 2 ;;
            -p|--path)      worktree_path="$2"; shift 2 ;;
            -r|--remote)    remote="$2"; shift 2 ;;
            --no-track)     track="false"; shift ;;
            -h|--help)
                cat <<'H'
Usage: git_worktree_setup <ssh-url> [-d <anchor-dir>] [-b <branch>] [-p <worktree-path>] [-r <remote>] [--no-track]
Creates a bare anchor repo at <anchor-dir> (default: $PWD/<repo>.git) and a first worktree for <branch>.
H
                return 0 ;;
            *) echo "Unknown arg: $1" >&2; return 2 ;;
        esac
    done

    if [[ -z "$ssh_url" ]]; then
        echo "Error: SSH URL required (e.g. git@github.com:org/repo.git)" >&2
        return 2
    fi
    if ! command -v git >/dev/null 2>&1; then
        echo "Error: git not found" >&2
        return 2
    fi

    local name parent
    name="$(basename "${ssh_url%.git}")"

    # Default: put the anchor in the current working directory
    anchor_dir="${anchor_dir:-$PWD/${name}.git}"

    # Clone or refresh anchor
    if [[ -d "$anchor_dir" ]]; then
        echo "Anchor already exists: $anchor_dir"
        git --git-dir="$anchor_dir" rev-parse --is-bare-repository >/dev/null 2>&1 || {
            echo "Error: $anchor_dir exists but is not a bare repo." >&2
            return 2
        }
        git --git-dir="$anchor_dir" remote set-url "$remote" "$ssh_url" 2>/dev/null || true
        git --git-dir="$anchor_dir" fetch "$remote" --prune || true
    else
        mkdir -p "$(dirname "$anchor_dir")" || {
            echo "Error: cannot create parent directory for $anchor_dir" >&2
            return 2
        }
        echo "+ git clone --bare \"$ssh_url\" \"$anchor_dir\""
        git clone --bare --origin "$remote" "$ssh_url" "$anchor_dir" || return 2
    fi

    git --git-dir="$anchor_dir" config worktree.guessRemote true >/dev/null 2>&1 || true

    # Determine default branch if not provided
    if [[ -z "$branch" ]]; then
        branch="$(git --git-dir="$anchor_dir" symbolic-ref --quiet --short "refs/remotes/${remote}/HEAD" 2>/dev/null | sed "s#${remote}/##")"
        branch="${branch:-main}"
    fi

    # Default worktree: sibling of anchor (../<repo>__<branch>)
    parent="$(dirname "$anchor_dir")"
    worktree_path="${worktree_path:-${parent}/${name}__${branch//\//_}}"

    if [[ -d "$worktree_path/.git" || -f "$worktree_path/.git" ]]; then
        echo "Worktree already exists at: $worktree_path"
        (cd "$worktree_path" && git status -sb) || true
        return 0
    fi
    mkdir -p "$(dirname "$worktree_path")" || {
        echo "Error: cannot create parent directory for $worktree_path" >&2
        return 2
    }

    # Ensure local branch exists in anchor
    if ! git --git-dir="$anchor_dir" show-ref --verify --quiet "refs/heads/${branch}"; then
        git --git-dir="$anchor_dir" fetch "$remote" --prune || true
        if git --git-dir="$anchor_dir" show-ref --quiet "refs/remotes/${remote}/${branch}"; then
            git --git-dir="$anchor_dir" branch "$branch" "${remote}/${branch}" || return 2
        else
            local head_ref
            head_ref="$(git --git-dir="$anchor_dir" rev-parse "${remote}/HEAD" 2>/dev/null)"
            if [[ -n "$head_ref" ]]; then
                git --git-dir="$anchor_dir" branch "$branch" "$head_ref" || return 2
            else
                echo "Error: cannot determine start point for '$branch'." >&2
                return 2
            fi
        fi
        if [[ "$track" == "true" ]]; then
            git --git-dir="$anchor_dir" branch --set-upstream-to "${remote}/${branch}" "$branch" >/dev/null 2>&1 || true
        fi
    fi

    echo "+ git --git-dir=\"$anchor_dir\" worktree add \"$worktree_path\" \"$branch\""
    git --git-dir="$anchor_dir" worktree add "$worktree_path" "$branch" || return 2

    echo "✔ Anchor:   $anchor_dir"
    echo "✔ Worktree: $worktree_path  (branch: $branch)"
    echo "  Next: cd \"$worktree_path\""
}


# git_worktree_spawn <branch> [-s <start-point>] [-p <worktree-path>] [-a <anchor-dir>] [-r <remote>] [--no-track] [--force]
# From inside a worktree *or* inside the bare anchor, create another worktree in ../<repo>__<branch>.
function git_worktree_spawn() {
    local branch start_point worktree_path anchor_dir remote track force
    branch="$1"; shift || true
    start_point=""
    worktree_path=""
    anchor_dir=""
    remote="origin"
    track="true"
    force="false"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s|--start-point) start_point="$2"; shift 2 ;;
            -p|--path)        worktree_path="$2"; shift 2 ;;
            -a|--anchor)      anchor_dir="$2"; shift 2 ;;
            -r|--remote)      remote="$2"; shift 2 ;;
            --no-track)       track="false"; shift ;;
            -f|--force)       force="true"; shift ;;
            -h|--help)
                cat <<'H'
Usage: git_worktree_spawn <branch> [options]
Create a new worktree for <branch>, discovering the bare anchor automatically.

Options
  -s, --start-point <rev>   Start point if creating the branch (default: current @{u} or HEAD if in a worktree; otherwise remote HEAD)
  -p, --path <dir>          Where to place the worktree (default: ../<repo>__<branch>)
  -a, --anchor <dir>        Explicit path to the bare anchor (if not running in a worktree/anchor)
  -r, --remote <name>       Remote to use (default: origin)
      --no-track            Do not set upstream even if remote branch exists
  -f, --force               Pass --force to 'git worktree add'
H
                return 0 ;;
            *) echo "Unknown arg: $1" >&2; return 2 ;;
        esac
    done

    if [[ -z "$branch" ]]; then
        echo "Error: branch name required" >&2
        return 2
    fi
    if ! command -v git >/dev/null 2>&1; then
        echo "Error: git not found" >&2
        return 2
    fi

    # --- discover the bare anchor ---
    if [[ -z "$anchor_dir" ]]; then
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            # In a linked worktree: common-dir points to the anchor
            anchor_dir="$(git rev-parse --git-common-dir)"
        elif git rev-parse --is-bare-repository >/dev/null 2>&1; then
            # Inside the bare anchor
            anchor_dir="$(git rev-parse --git-dir)"
        fi
    fi
    if [[ -z "$anchor_dir" ]]; then
        echo "Error: cannot determine anchor. Run from a worktree/anchor or pass -a <anchor.git>." >&2
        return 2
    fi
    if [[ "$(git --git-dir="$anchor_dir" rev-parse --is-bare-repository 2>/dev/null)" != "true" ]]; then
        echo "Error: '$anchor_dir' is not a bare repo (anchor)." >&2
        return 2
    fi

    git --git-dir="$anchor_dir" config worktree.guessRemote true >/dev/null 2>&1 || true

    # --- name bits and default path ---
    local repo parent
    repo="$(basename "${anchor_dir%.git}")"

    if [[ -z "$worktree_path" ]]; then
        # Default parent is one level up from where we are now; if that fails, use the anchor's parent.
        parent="$(cd .. 2>/dev/null && pwd)"
        parent="${parent:-$(dirname "$anchor_dir")}"
        worktree_path="${parent}/${repo}__${branch//\//_}"
    fi

    # --- ensure the branch exists in the anchor, else create it ---
    if ! git --git-dir="$anchor_dir" show-ref --verify --quiet "refs/heads/${branch}"; then
        if [[ -z "$start_point" ]]; then
            if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
                # Prefer upstream of current branch; else current HEAD
                start_point="$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || true)"
                start_point="${start_point:-$(git rev-parse HEAD)}"
            else
                # From the anchor: prefer remote/<branch>, else remote HEAD, else main
                if git --git-dir="$anchor_dir" show-ref --quiet "refs/remotes/${remote}/${branch}"; then
                    start_point="${remote}/${branch}"
                else
                    local def
                    def="$(git --git-dir="$anchor_dir" symbolic-ref --quiet --short "refs/remotes/${remote}/HEAD" 2>/dev/null | sed "s#${remote}/##")"
                    start_point="${remote}/${def:-main}"
                fi
            fi
        fi
        echo "+ git --git-dir=\"$anchor_dir\" branch \"$branch\" \"$start_point\""
        git --git-dir="$anchor_dir" branch "$branch" "$start_point" || return 2

        if [[ "$track" == "true" ]] && git --git-dir="$anchor_dir" show-ref --quiet "refs/remotes/${remote}/${branch}"; then
            git --git-dir="$anchor_dir" branch --set-upstream-to "${remote}/${branch}" "$branch" >/dev/null 2>&1 || true
        fi
    fi

    # --- add the worktree ---
    mkdir -p "$(dirname "$worktree_path")" || {
        echo "Error: cannot create parent directory for $worktree_path" >&2
        return 2
    }

    echo "+ git --git-dir=\"$anchor_dir\" worktree add ${force:+--force }\"$worktree_path\" \"$branch\""
    if [[ "$force" == "true" ]]; then
        git --git-dir="$anchor_dir" worktree add --force "$worktree_path" "$branch" || return 2
    else
        git --git-dir="$anchor_dir" worktree add "$worktree_path" "$branch" || return 2
    fi

    echo "✔ Anchor:   $anchor_dir"
    echo "✔ Worktree: $worktree_path  (branch: $branch)"
    echo "  Next: cd \"$worktree_path\""
}


function get_git_url() {
    local open_url=false

    if [[ "$1" == "-o" || "$1" == "--open" ]]; then
        open_url=true
        shift
    fi

    local remote_url
    remote_url=$(git remote get-url origin 2>/dev/null) || {
        echo "Error: could not get remote URL (are you in a git repo?)" >&2
        return 1
    }

    # Convert SSH to HTTPS for common providers (GitHub, GitLab, Bitbucket, etc.)
    local https_url="$remote_url"
    if [[ $remote_url =~ ^git@([^:]+):(.+)$ ]]; then
        local host="${BASH_REMATCH[1]}"
        local path="${BASH_REMATCH[2]}"
        https_url="https://${host}/${path}"
    fi

    # Remove .git suffix only if at the end
    https_url="${https_url%.git}"

    if $open_url; then
        # Detect and use appropriate opener for each platform
        if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
            # Windows Subsystem for Linux
            wslview "$https_url" 2>/dev/null || explorer.exe "$https_url"
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            open "$https_url"
        elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
            # Git Bash / Cygwin on Windows
            cmd.exe /c start "" "$https_url" 2>/dev/null
        elif command -v xdg-open >/dev/null 2>&1; then
            xdg-open "$https_url" >/dev/null 2>&1 &
        else
            echo "Could not detect a way to open the browser." >&2
            echo "$https_url"
            return 1
        fi
    else
        echo "$https_url"
    fi
}
