# Applications
alias ff="fastfetch"
alias f="fzf"
alias mc="mc --nosubshell -S ~/.config/mc/skins/dracula256.ini"

# Docker commands
alias dk='docker'
alias dcup='docker compose up'
alias dcdown='docker compose down'
alias docker_clean='docker system prune -a --volumes'
alias docker_clean_images='docker rm $(docker ps -aq)'


# Pip aliases
alias pip="uv pip"
alias pyvenv="python3 -m venv venv"
alias pipreqs="pip3 install -r requirements.txt"
alias pyenv="pyvenv && act && pipreqs"
