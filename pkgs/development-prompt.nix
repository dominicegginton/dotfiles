{ makeSetupHook, writeScript, stdenv, git }:

workspaceName: (makeSetupHook { name = "development-prompt"; }
  (writeScript "development-prompt" ''
    #!${stdenv.shell}
    function parse_git_dirty {
      [[ $(${git}/bin/git status --porcelain 2> /dev/null) ]] && echo "*"
    }
    function parse_git_branch {
      ${git}/bin/git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/ (\1$(parse_git_dirty))/"
    }
    export PS1="\[\e[1;31m\][${workspaceName}]\[\e[0m\] \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch) \[\e[1;35m\]$\[\e[0m\] "
  ''))
