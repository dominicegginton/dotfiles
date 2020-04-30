autoload -U promptinit; promptinit
prompt spaceship

export PATH=/usr/local/bin:$PATH

alias ls='ls -l'
alias cp='cp -iv' 
alias mv='mv -iv' 
alias mkdir='mkdir -pv' 
alias ll='ls -FGlAhp'
alias less='less -FSRXc'
cd() { builtin cd "$@"; ls; }
alias cd..='cd ../' 
alias ..='cd ../'
alias ...='cd ../../'
alias f='open -a Finder ./'
alias chrome='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'
alias python='python3'
alias pip='pip3'
alias g++='g++ -std=c++14'

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# Load Git completion
zstyle ':completion:*:*:git:*' script ~/.zsh/zsh-git/git-completion.bash
fpath=(~/.zsh $fpath)

autoload -Uz compinit && compinit
