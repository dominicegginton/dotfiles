{pkgs, ...}: let
  inherit (pkgs.stdenv) isDarwin;
in
  pkgs.writeShellApplication {
    name = "hibernate-host";

    text =
      if isDarwin
      then ''
        sudo pmset sleepnow
      ''
      else ''
        sudo systemctl hibernate
      '';
  }
