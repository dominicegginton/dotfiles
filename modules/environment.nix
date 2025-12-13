{ pkgs, ... }:

{
  config = {
    environment = {
      etc.issue.text = "Residence";
      loginShellInit = ''
        if [[ $(type -t "__vte_prompt_command") != function ]]; then
          function __vte_prompt_command(){
            return 0
          }
        fi
        ${pkgs.nix-github-authentication}/bin/nix-github-authentication";
      '';
      variables = {
        EDITOR = "nvim";
        SYSTEMD_EDITOR = "nvim";
        VISUAL = "nvim";
        PAGER = "less";
      };
    };
  };
}

