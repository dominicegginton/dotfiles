{ pkgs, ... }:

{
  config = {
    environment = {
      etc.issue.text = "Residence";
      loginShellInit = ''
        __vte_prompt_command() { true; }
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

