{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv) isLinux isDarwin;
in

with lib;

{
  imports = [
    ./git.nix
    ./neovim.nix
    ./tmux.nix
    ./zsh.nix
  ];

  config = {
    programs = {
      bash.enable = true;
      info.enable = true;
      hstr.enable = true;
      nix-index-database.comma.enable = true;
    };

    home.packages =
      with pkgs; [
        git
        git-lfs
        git-sync
        gnupg
        tmux
        twm
        jq
        fx
        glow
        nix-output-monitor
        nix-tree
        nix-melt
        deadnix
        nix-init
        manix
        nix-du
        ranger
        todo
      ]
      ++ (if isLinux then [ ncdu ] else [ ])
      ++ (if isDarwin then [ ] else [ ]);
  };
}
