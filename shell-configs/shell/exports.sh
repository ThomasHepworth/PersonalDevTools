export SHELL_HOME="$HOME/shell"
export MANPATH="/usr/local/man:$MANPATH"
export HOMEBREW_PREFIX=$(brew --prefix)/

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export AWS_CLI_AUTO_PROMPT=on-partial

# Eval shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
eval "$(atuin init zsh)"
