# exports
set -gx EDITOR nvim
set -gx LANG en_GB.UTF-8
set -x GPG_TTY (tty)
# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
