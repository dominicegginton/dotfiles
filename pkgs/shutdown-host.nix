{pkgs, ...}: let
  inherit (pkgs.stdenv) isDarwin;
in
  pkgs.writeShellApplication {
    name = "shutdown-host";

    text =
      if isDarwin
      then ''
        sudo shutdown -h now
      ''
      else ''
        shutdown 0
      '';
  }
