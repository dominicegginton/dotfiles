{ lib, ... }:

{
    environment = {
      etc.issue.text = lib.mkDefault "Residence";

      loginShellInit = lib.mkDefault ''
        __vte_prompt_command() { true; }
      '';

      variables = {
        EDITOR = "nvim";
        SYSTEMD_EDITOR = "nvim";
        VISUAL = "nvim";
        PAGER = "less";
      };
  };
}

