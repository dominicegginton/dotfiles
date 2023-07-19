# !/bin/bash

# .bashrc
# Executed by bash for interactive shells in non-login mode.

# OPTION
set -o vi

# ENVIRONMENT VARIABLES
export LANG=en_GB.UTF-8
export EDITOR=vim

# PATH CONFIGURATION
export PATH="$HOME/.bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.npm-global:$PATH"
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
export PATH="$HOME/.nvm:$PATH"

[ -s "$HOME/.nvm/nvm.sh" ] && \. "$HOME/.nvm/nvm.sh" --no-use
[ -s "$HOME/.nvm/bash_completion" ] && \. "$HOME/.nvm/bash_completion"

# PROMPT
if [[ "$SSH_CLIENT" ]]; then
  export PS1="\[\e[1;31m\]\u\[\e[0m\]@\[\e[1;32m\]\h\[\e[0m\] \[\e[1;34m\]\w\[\e[0m\]\n\[\033[0;35m\]\$\[\033[m\] "
else
  export PS1="\[\e[1;34m\]\w\[\e[0m\]\n\[\033[0;35m\]\$\[\033[m\] "
fi
