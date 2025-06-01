{ pkgs, lib, ... }:

{
  config = {
    programs.gpg.enable = true;
    services.gpg-agent = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      enableSshSupport = true;
      enableZshIntegration = true;
    };
  };
}
