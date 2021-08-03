# ALIAS
alias ls='exa -F --long --header --git'
alias la='exa -aF --long --header --git'
alias exa='exa -F --long --header --git'
alias tree='exa --long --header --git --tree'
alias pacman='paru'
alias dotfiles='code ~/.dotfiles'

# ENVIROMENT VARIABLESrts
export GPG_TTY=$(tty)
export EDITOR=nano
export LANG=en_GB.UTF-8


# PARSE GIT STATUS
function parse_git_status {
        status=`git status 2> /dev/null`
        dirty=`echo -n "${status}" 2> /dev/null | grep -q "Changes not staged for commit" 2> /dev/null; echo "$?"`
        untracked=`echo -n "${status}" 2> /dev/null | grep -q "Untracked files" 2> /dev/null; echo "$?"`
        ahead=`echo -n "${status}" 2> /dev/null | grep -q "Your branch is ahead" 2> /dev/null; echo "$?"`
        behind=`echo -n "${status}" 2> /dev/null | grep -q "Your branch is behind" 2> /dev/null; echo "$?"`
        newfile=`echo -n "${status}" 2> /dev/null | grep -q "new file:" 2> /dev/null; echo "$?"`
        renamed=`echo -n "${status}" 2> /dev/null | grep -q "renamed:" 2> /dev/null; echo "$?"`
        bits=''
        if [ "${dirty}" == "0" ]; then bits="${bits}M "; fi
        if [ "${untracked}" == "0" ]; then bits="${bits}U "; fi
        if [ "${newfile}" == "0" ]; then bits="${bits}N "; fi
        if [ "${ahead}" == "0" ]; then bits="${bits}⇡ "; fi
        if [ "${behind}" == "0" ]; then bits="${bits}⇣ "; fi
        if [ "${renamed}" == "0" ]; then bits="${bits}R "; fi
        echo "${bits}"
}

# PARSE GIT BRANCH
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/ \1/"
}

# alisas
alias ls='exa -F --long --header --git'
alias la='exa -aF --long --header --git'
alias exa='exa -F --long --header --git'
alias tree='exa --long --header --git --tree'
alias pacman='paru'
alias dotfiles='code ~/.dotfiles'

# options
setopt AUTOCD
setopt COMPLETE_ALIASES
setopt CORRECT
setopt PROMPT_SUBST

# PROMPT
NEWLINE=$'\n'
if [[ "$SSH_CLIENT" ]]; then
    PROMPT="%F{green}%1\u@\h %F{blue}%1\w$%F{magenta}%1\$(parse_git_branch)%F{yellow}%1\$(parse_git_status)\n%F{magenta}%1❯$CLEAR"
elsez
    PROMPT="%F{blue}%1 %~ %F{magenta}%1$(parse_git_branch)%F{yellow}%1$(parse_git_status) $(NEWLINE) %F{magenta}%1l%F{clear}"
fi
