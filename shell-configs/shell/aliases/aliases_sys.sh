# Bash aliases
alias ls='lsd'
alias c='clear'
alias e='exit'
alias o="open ."
alias lsdot="ls -ld .?*"
# confirm before overwriting something
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'
alias grep='grep --color=auto'

# System monitoring
alias psmem="ps aux | sort -nrk 4,4 | head -5 | awk 'BEGIN { printf(\"%-10s %-10s %-10s %-10s %-30s\\n\", \"USER\", \"PID\", \"%CPU\", \"%MEM\", \"COMMAND\"); } { printf(\"%-10s %-10s %-10s %-10s %-30s\\n\", \$1, \$2, \$3, \$4, \$11); }'"
alias pscpu="ps aux | sort -nrk 3,3 | head -5 | awk 'BEGIN { printf(\"%-10s %-10s %-10s %-10s %-30s\\n\", \"USER\", \"PID\", \"%CPU\", \"%MEM\", \"COMMAND\"); } { printf(\"%-10s %-10s %-10s %-10s %-30s\\n\", \$1, \$2, \$3, \$4, \$11); }'"
