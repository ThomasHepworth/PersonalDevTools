# export HOMEBREW_PREFIX=
export SHELL_HOME="$HOME/shell"
export MANPATH="/usr/local/man:$MANPATH"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Eval shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
eval "$(atuin init zsh)"