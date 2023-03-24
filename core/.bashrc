# COLORS
RED="\[\033[0;31m\]"
GREEN="\[\033[0;32m\]"
YELLOW="\[\033[0;33m\]"
BLUE="\[\033[0;34m\]"
MAGENTA="\[\033[0;35m\]"
CYAN="\[\033[0;36m\]"
LIGHTGREY="\[\033[0;37m\]"
DARKGREY="\[\033[0;90m\]"
LIGHTRED="\[\033[0;91m\]"
LIGHTGREEN="\[\033[0;92m\]"
LIGHTYELLOW="\[\033[0;93m\]"
LIGHTBLUE="\[\033[0;94m\]"
LIGHTMAGENTA="\[\033[0;95m\]"
LIGHTCYAN="\[\033[0;96m\]"
WHITE="\[\033[0;97m\]"
CLEAR="\[\033[0m\]"

# ENVIROMENT VARIABLES
export GPG_TTY=$(tty)
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

# BASH OPTIONS
shopt -s cdable_vars
shopt -s cdspell
shopt -s checkhash
shopt -s checkwinsize
shopt -s histappend
shopt -s cmdhist
shopt -s dotglob
shopt -s expand_aliases
shopt -u failglob
shopt -s extglob
shopt -s extquote
shopt -s nocaseglob
shopt -s hostcomplete
shopt -s interactive_comments

# PATH
export PATH="$PATH:~/Library/Python/3.9/bin"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# PROMPT
if [[ "$SSH_CLIENT" ]]; then
    export PS1="$GREEN\u@\h $BLUE\w$MAGENTA\$(parse_git_branch) $YELLOW\$(parse_git_status)\n$MAGENTA\$$CLEAR "
else
    export PS1="$BLUE\w$MAGENTA\$(parse_git_branch) $YELLOW\$(parse_git_status)\n$MAGENTA\$$CLEAR "
fi
