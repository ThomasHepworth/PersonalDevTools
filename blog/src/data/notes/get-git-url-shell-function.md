---
title: "One command to open any repo in your browser"
pubDatetime: 2025-12-23T10:00:00Z
type: snippet
tags:
  - shell
  - git
  - tooling
---

One frustration I used to have regularly when working on coding projects was this constant need to navigate to a repository in my browser, for a project I was working on locally. You follow standard gitflows locally and then... it was just tedious.

So I wrote a simple shell function to assist in this process:
```bash
get_git_url -o
```

From *any directory* inside a git repo, it instantly opens that repository in your browser. No copying URLs, no bookmark hunting.

```bash
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

    # Convert SSH to HTTPS for common providers
    local https_url="$remote_url"
    if [[ $remote_url =~ ^git@([^:]+):(.+)$ ]]; then
        local host="${BASH_REMATCH[1]}"
        local path="${BASH_REMATCH[2]}"
        https_url="https://${host}/${path}"
    fi

    https_url="${https_url%.git}"

    if $open_url; then
        if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
            wslview "$https_url" 2>/dev/null || explorer.exe "$https_url"
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            open "$https_url"
        elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
            cmd.exe /c start "" "$https_url" 2>/dev/null
        elif command -v xdg-open >/dev/null 2>&1; then
            xdg-open "$https_url" >/dev/null 2>&1 &
        else
            echo "$https_url"
            return 1
        fi
    else
        echo "$https_url"
    fi
}
```

**Why it's great:**
- Works with SSH or HTTPS remotes (auto-converts SSH → HTTPS)
- Cross-platform: macOS, Linux, WSL, Git Bash
- Without `-o`, just prints the URL (useful for piping)
- Works with GitHub, GitLab, Bitbucket—any git host

I use this dozens of times a day. Add it to your `.zshrc` or `.bashrc` and thank yourself later.
