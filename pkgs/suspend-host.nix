{pkgs, ...}: let
  inherit (pkgs.stdenv) isDarwin;
in
  pkgs.writeShellApplication {
    name = "suspend-host";

    text =
      if isDarwin
      then ''
        osascript -e 'tell application "System Events" to sleep'
      ''
      else ''
        systemctl suspend
      '';
  }
