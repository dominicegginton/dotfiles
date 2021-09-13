# ALIAS
alias ls='exa -F --long --header --git'
alias la='exa -aF --long --header --git'
alias exa='exa -F --long --header --git'
alias tree='exa --long --header --git --tree'
alias pacman='paru'
alias dotfiles='code ~/.dotfiles'

# ENVIROMENT VARIABLES
export GPG_TTY=$(tty)
export EDITOR=nano
export LANG=en_GB.UTF-8

# PARSE GIT STATUS
function parse_git_status {
        git_status=`git status 2> /dev/null`
        dirty=`echo -n "${git_status}" 2> /dev/null | grep -q "Changes not staged for commit" 2> /dev/null; echo "$?"`
        untracked=`echo -n "${git_status}" 2> /dev/null | grep -q "Untracked files" 2> /dev/null; echo "$?"`
        ahead=`echo -n "${git_status}" 2> /dev/null | grep -q "Your branch is ahead" 2> /dev/null; echo "$?"`
        behind=`echo -n "${git_status}" 2> /dev/null | grep -q "Your branch is behind" 2> /dev/null; echo "$?"`
        newfile=`echo -n "${git_status}" 2> /dev/null | grep -q "new file:" 2> /dev/null; echo "$?"`
        renamed=`echo -n "${git_statu}s" 2> /dev/null | grep -q "renamed:" 2> /dev/null; echo "$?"`
        bits=''
        remote=''
        if [ "${dirty}" = "0" ]; then bits="${bits}M"; fi
        if [ "${untracked}" = "0" ]; then bits="${bits}U"; fi
        if [ "${newfile}" = "0" ]; then bits="${bits}N"; fi
        if [ "${renamed}" = "0" ]; then bits="${bits}R"; fi
        if [ "${ahead}" = "0" ]; then remote="${remote}⇡"; fi
        if [ "${behind}" = "0" ]; then remote="${remote}⇣"; fi
        echo "${bits}${remote}"
}

# PARSE GIT BRANCH
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/ \1/"
}

# ZSH OPTIONS
setopt AUTO_CD
setopt CORRECT_ALL
setopt CHECK_JOBS
setopt LONG_LIST_JOBS
setopt HIST_APPEND
setopt ALIASES
setopt INTERACTIVE_COMMENTS

# PROMPT
if [[ "$SSH_CLIENT" ]]; then
  PROMPT="%F{green}%n@%m %F{blue}%~%F{magenta}$(parse_git_branch) %F{yellow}$(parse_git_status)$prompt_newline%F{magenta}$%F{default} "
else
  PROMPT="%F{blue}%~%F{magenta}$(parse_git_branch) %F{yellow}$(parse_git_status)$prompt_newline%F{magenta}$%F{default} "
fi
