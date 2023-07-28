# !/bin/bash

# .bashrc
# Executed by bash for interactive shells in non-login mode.

# OPTIONS
set -o vi
shopt -s histappend
shopt -s checkwinsize
shopt -s cdspell
shopt -s cmdhist
shopt -s nocaseglob
shopt -s dotglob
shopt -s extglob

# ALIAS
alias ls='ls -l --color=auto'
alias la='ls -la --color=auto'

# ENVIRONMENT VARIABLES
export LANG=en_GB.UTF-8
export EDITOR=vim
export GPG_TTY=$(tty)

# PATH
export PATH="$HOME/.bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.npm-global:$PATH"
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
export PATH="$HOME/.nvm:$PATH"
export PATH="$HOME/.docker/bin:$PATH"

# PROMPT
if [[ "$SSH_CLIENT" ]]; then
  export PS1="\[\e[1;31m\]\u\[\e[0m\]@\[\e[1;32m\]\h\[\e[0m\] \[\e[1;34m\]\w\[\e[0m\]\n\[\033[0;35m\]\$\[\033[m\] "
else
  export PS1="\[\e[1;34m\]\w\[\e[0m\]\n\[\033[0;35m\]\$\[\033[m\] "
fi

# NVM
[ -s "$HOME/.nvm/nvm.sh" ] && \. "$HOME/.nvm/nvm.sh" --no-use
[ -s "$HOME/.nvm/bash_completion" ] && \. "$HOME/.nvm/bash_completion"
