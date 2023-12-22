{pkgs, ...}: let
  inherit (pkgs.stdenv) isDarwin;
in
  pkgs.writeShellApplication {
    name = "reboot-host";

    text =
      if isDarwin
      then ''
        sudo shutdown -r now
      ''
      else ''
        reboot
      '';
  }
