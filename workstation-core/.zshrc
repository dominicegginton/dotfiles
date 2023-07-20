# !/bin/zsh

# .zshrc
# Executed by Zsh for interactive shells in non-login mode.

# OPTIONS
setopt VI
setopt HIST_APPEND
setopt AUTO_CD
setopt CORRECT_ALL
setopt CHECK_JOBS
setopt LONG_LIST_JOBS
setopt ALIASES
setopt INTERACTIVE_COMMENTS
setopt PROMPT_SUBST

# ALIAS
alias ls='exa -l --icons --git --group-directories-first'
alias la='exa -la --icons --git --group-directories-first'

# ENVIRONMENT VARIABLES
export LANG=en_GB.UTF-8
export EDITOR=nvim
export TERM=xterm-256color
export GPG_TTY=$(tty)

# PATH
export PATH="$HOME/.bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.npm-global:$PATH"
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
export PATH="$HOME/.nvm:$PATH"

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

# NVM
[ -s "$HOME/.nvm/nvm.sh" ] && \. "$HOME/.nvm/nvm.sh" --no-use
[ -s "$HOME/.nvm/bash_completion" ] && \. "$HOME/.nvm/bash_completion"
