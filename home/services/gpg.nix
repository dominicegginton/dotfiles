{
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkIf;
in {
  services = {
    gpg-agent = mkIf isLinux {
      enable = true;
      enableSshSupport = true;
      enableZshIntegration = true;
    };
  };

  programs.gpg.enable = true;

  home.packages = with pkgs; [
    gnupg
    workspace.gpg-import-keys
  ];
}
