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
set __fish_git_prompt_char_dirtystate 'M'
set __fish_git_prompt_char_invalidstate '#'
set __fish_git_prompt_char_stashstate '$'
set __fish_git_prompt_char_stagedstate 'S'
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
set __fish_git_prompt_color_stagedstate blue
set __fish_git_prompt_color_stashstate magenta
set __fish_git_prompt_color_untrackedfiles green
set __fish_git_prompt_color_upstream blue

# SET PROMPT OPTIONS
set -U fish_prompt_pwd_dir_length 0

# PATH
set -U fish_user_paths ~/Library/Python/3.9/bin $fish_user_paths

# FISH PROMPT
function fish_prompt
  set -l last_status $status
  if test $SSH_CLIENT
    set_color green
    echo -n "$USER"@(hostname)" "
  end
  set_color blue
  echo (prompt_pwd) (__fish_git_prompt "%s")
  if test $last_status -eq 0
    set_color magenta
  else
    set_color red
  end
  echo "\$ "
end