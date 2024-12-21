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
        git-sync
        gnupg
        tmux
        twm
        fzf
        ripgrep
        jq
        fx
        glow
        nix-output-monitor
        deadnix
      ]
      ++ (if isLinux then [ ncdu ] else [ ])
      ++ (if isDarwin then [ ] else [ ]);
  };
}
