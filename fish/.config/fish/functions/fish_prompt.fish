# GIT PROMPT
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showupstream 'verbose'
set __fish_git_prompt_showstashstate 'yes'
set __fish_git_prompt_describe_style 'default'
set __fish_git_prompt_showcolorhints 'yes'
set __fish_git_prompt_char_stateseparator ' '

# GIT CHARACTERS
set __fish_git_prompt_char_cleanstate ''
set __fish_git_prompt_char_dirtystate 'M '
set __fish_git_prompt_char_invalidstate '# '
set __fish_git_prompt_char_stagedstate '⇢ '
set __fish_git_prompt_char_untrackedfiles 'U'
set __fish_git_prompt_char_upstream_prefix ' '
set __fish_git_prompt_char_upstream_equal ''
set __fish_git_prompt_char_upstream_ahead '⇡'
set __fish_git_prompt_char_upstream_behind '⇣'
set __fish_git_prompt_char_upstream_diverged '⇡⇣'

# GIT COLORS
set __fish_git_prompt_color_branch magenta
set __fish_git_prompt_color_branch_detached red
set __fish_git_prompt_color_flags yellow
set __fish_git_prompt_color_cleanstate green
set __fish_git_prompt_color_dirtystate yellow
set __fish_git_prompt_color_invalidstate red
set __fish_git_prompt_color_stagedstate yellow
set __fish_git_prompt_color_stashstate blue
set __fish_git_prompt_color_untrackedfiles green
set __fish_git_prompt_color_upstream blue

  set_color $color
  printf $string
  set_color normal
end

function _prompt_color_for_status
  if test $argv[1] -eq 0
    echo magenta
  else
    echo red
  end
end

function fish_prompt
  set -l last_status $status
  _print_in_color "\n"(prompt_pwd) blue
  __fish_git_prompt " %s"
  _print_in_color "\n❯ " (_prompt_color_for_status $last_status)
end