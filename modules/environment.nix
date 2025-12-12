{ pkgs, ... }:

{
  config = {
    environment = {
      etc.issue.text = "Residence";
      loginShellInit = "${pkgs.nix-github-authentication}/bin/nix-github-authentication";
      variables = {
        EDITOR = "nvim";
        SYSTEMD_EDITOR = "nvim";
        VISUAL = "nvim";
        PAGER = "less";
      };
    };
  };
}

