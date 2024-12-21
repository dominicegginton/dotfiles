{ pkgs, lib, ... }:

let
  inherit (pkgs.stdenv) isLinux;
in

with lib;

{
  config = {
    programs.gpg.enable = true;
    services.gpg-agent = mkIf isLinux {
      enable = true;
      enableSshSupport = true;
      enableZshIntegration = true;
    };
  };
}
