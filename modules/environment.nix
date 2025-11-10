{ pkgs, ... }:

{
  config = {
    environment = {
      # set system issue file text - shown on tty login prompts 
      etc.issue.text = "Residence";

      # add zsh pkg to system shells 
      shells = [ pkgs.zsh ];

      # link zsh to /bin/sh
      pathsToLink = [ "/share/zsh" ];

      variables = {
        EDITOR = "nvim";
        SYSTEMD_EDITOR = "nvim";
        VISUAL = "nvim";
        PAGER = "less";
      };
    };
  };
}

