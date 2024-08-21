# Git aliases
alias gs='git status'
alias gd='git diff'
alias gl='git log'
alias gc='git checkout'
alias gp='git push'
alias gm='git merge'
alias gpl='git pull'
alias gca='git commit --amend'
alias gol5='git log --oneline -n 5'
alias grh='git reset --hard'
alias pr='git pull --rebase'
alias gbr='git branch'
alias gcm='git commit -m'
alias gds='git diff --stat'
alias amend_add='git commit --amend --no-edit'

# Git worktrees
alias gwt='git worktree'
alias gwtl='git worktree list'
alias gwtp='git worktree prune'
alias gwta='git worktree add'
alias gwtam='function _gwtam() { git worktree add "$1" main; }; _gwtam'

