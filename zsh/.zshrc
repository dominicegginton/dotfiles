# gpg
export GPG_TTY=$(tty)

# alisas
alias ls'exa --long --header --git'
alias exa='exa --long --header --git'
alias tree='exa --long --header --git --tree'
alias pacman='paru'
alias yay='paru'
alias code='code --enable-proposed-api GitHub.vscode-pull-request-github --enable-proposed-api ms-python.python'

# options
setopt correct
setopt autocd
setopt nocheckjobs

zstyle :prompt:pure:path color blue
zstyle :prompt:pure:prompt:success color green
zstyle :prompt:pure:prompt:error color red
zstyle :prompt:pure:git:stash show yes

autoload -U promptinit; promptinit
prompt pure
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fpath=(/usr/share/zsh/site-functions $fpath)

ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=red
ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=red,standout
ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=green,underline
ZSH_HIGHLIGHT_STYLES[command]=fg=green
ZSH_HIGHLIGHT_STYLES[precommand]=fg=magenta
ZSH_HIGHLIGHT_STYLES[builtin]=fg=green
ZSH_HIGHLIGHT_STYLES[function]=fg=green
ZSH_HIGHLIGHT_STYLES[path]=fg=forground,underline
ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue
ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=forground,underline
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=none
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=none
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=cyan
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=cyan
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=cyan
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=cyan