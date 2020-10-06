# gpg
export GPG_TTY=$(tty)

# alisas
alias ls='ls -l --color'
alias tree='tree -C'
alias code='code --enable-proposed-api GitHub.vscode-pull-request-github --enable-proposed-api ms-python.python'

# options
setopt correct
setopt autocd
setopt nocheckjobs

zstyle :prompt:pure:path color '#1cdc9a'
zstyle :prompt:pure:prompt:error color '#c0392b'
zstyle :prompt:pure:git:stash show yes

autoload -U promptinit; promptinit
prompt pure
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fpath=(/usr/share/zsh/site-functions $fpath)

ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg='#1cdc9a',underline
ZSH_HIGHLIGHT_STYLES[precommand]=fg='#1cdc9a',underline
ZSH_HIGHLIGHT_STYLES[arg0]=fg='#1cdc9a'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=cyan
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=cyan