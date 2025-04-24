{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv) isLinux isDarwin;
in

with lib;

{
  config = {
    programs = {
      bash.enable = true;
      info.enable = true;
      hstr.enable = true;
    };

    home.packages =
      with pkgs; [
        git
        git-lfs
        gnupg
        twm
        fzf
        ripgrep
        jq
        fx
        nix-output-monitor
      ]
      ++ (if isLinux then [ ncdu ] else [ ])
      ++ (if isDarwin then [ ] else [ ]);
  };
}
