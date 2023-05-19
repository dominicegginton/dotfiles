# !/bin/bash

# .bashrc
# Executed by bash(1) for interactive shells in non-login mode.

# SOURCE GLOBAL DEFINITIONS
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# ALIASES
alias ls='ls -Gl --color=auto'

# ENVIRONMENT VARIABLES
export LANG=en_GB.UTF-8
export EDITOR=vim
export GPG_TTY=$(tty)

# BASH OPTIONS
shopt -s histappend # append to history, don't overwrite it
shopt -s checkwinsize # check window size after each command
shopt -s globstar # **/ matches all files and zero or more directories and subdirectories
shopt -s extglob # enable extended pattern matching features
shopt -s cdspell # correct minor spelling errors when using cd
shopt -s nocaseglob # case insensitive globbing
shopt -s nocasematch # case insensitive matching
shopt -s dotglob # include hidden files in globbing
shopt -s expand_aliases # expand aliases
shopt -s histverify # don't execute immediately upon history expansion
shopt -s cmdhist # save multi-line commands to history as a single line

# PATH CONFIGURATION
export PATH="$HOME/.bin:$PATH" # user bin directory
export PATH="$HOME/.local/bin:$PATH" # user local bin directory
export PATH="$HOME/.cargo/bin:$PATH" # rust bin directory

# PROMPT
if [[ "$SSH_CLIENT" ]]; then
  export PS1="\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\] \$ "
else
  export PS1="\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\] \$ "
fi
