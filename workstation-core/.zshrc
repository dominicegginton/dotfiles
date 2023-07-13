# !/bin/zsh

# .zshrc
# ZSH configuration file

# Source bash configuratio

# ALIAS
alias ls='ls -Gl --color=auto'

# ENVIRONMENT VARIABLES
export LANG=en_GB.UTF-8
export EDITOR=nvim
export TERM=xterm-256color
export GPG_TTY=$(tty)

# ZSH OPTIONS
setopt AUTO_CD
setopt CORRECT_ALL
setopt CHECK_JOBS
setopt LONG_LIST_JOBS
setopt HIST_APPEND
setopt ALIASES
setopt INTERACTIVE_COMMENTS
setopt PROMPT_SUBST
setopt VI

# PATH CONFIGURATION
export PATH="$HOME/.bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.npm-global:$PATH"
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"

# PROMPT
autoload -U colors && colors
autoload -Uz vcs_info
autoload -Uz promptinit && promptinit
zstyle ':vcs_info:git:*' formats '%b '
precmd() { vcs_info }
if [[ "$SSH_CLIENT" ]]; then
  PROMPT='%F{red}%n@%m%f %F{blue}%~%f %F{yellow}${vcs_info_msg_0_}%f${prompt_newline}%(?.%F{magenta}$.%F{red}$)%f '
else 
  PROMPT='%F{blue}%~%f %F{yellow}${vcs_info_msg_0_}%f${prompt_newline}%(?.%F{magenta}$.%F{red}$)%f '
fi

