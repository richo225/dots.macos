################################################################################
###                         User Fish Aliases                                ###
################################################################################

# File system
alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff='fzf --preview "bat --style=numbers --color=always {}"'
alias cat='bat --theme=ansi'
alias cfg='n ~/.config'
alias fishcfg='n ~/.config/fish/'
alias ccleo='cd ~/cleo/meetcleo/'

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Neovim
alias vim='n'
alias nvim='n'
alias v='n'

# Git
alias g='git'
alias gd='git diff --name-only | fzf -m --ansi --preview="git diff --color=always -- {}"'
alias gl='git log --oneline --color=always --no-decorate | fzf --ansi --no-sort --preview="git show --color=always {1}" --preview-window=up:60%'
alias gcl='git clone'
alias gs='git status'
alias ga='git add'
alias gcm='git commit -m'
alias gc='git checkout'
alias gpush='git push'
alias gpull='git pull'

# Rails
alias dbdrop='rails db:drop'
alias dbcreate='rails db:create'
alias dbmigrate='rails db:migrate'
alias dbreset='rails db:reset'
alias dbsetup='rails db:setup'
alias dbseed='rails db:seed'
