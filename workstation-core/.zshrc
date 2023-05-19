# !/bin/zsh

# .zshrc
# ZSH configuration file

# ALIAS
alias ls='ls -Gl --color=auto'

# ENVIRONMENT VARIABLES
export LANG=en_GB.UTF-8
export EDITOR=nvim
export GPG_TTY=$(tty)

# ZSH OPTIONS
setopt AUTO_CD # cd to directory if command is not found
setopt CORRECT_ALL # correct command if typo
setopt CHECK_JOBS # check if jobs running on exit
setopt LONG_LIST_JOBS # list jobs in long format
setopt HIST_APPEND # append to history file
setopt ALIASES # expand aliases
setopt INTERACTIVE_COMMENTS # allow comments in interactive shell

# PATH CONFIGURATION
export PATH="$HOME/.bin:$PATH" # user bin directory
export PATH="$HOME/.local/bin:$PATH" # user local bin directory
export PATH="$HOME/.cargo/bin:$PATH" # rust bin directory

# PROMPT
if [[ -n "$SSH_CLIENT" ]]; then
    PROMPT='%F{red}%n%f@%F{green}%m%f:%F{blue}%~%f $ '
else
  PROMPT='%F{blue}%~%f $ '
fi
