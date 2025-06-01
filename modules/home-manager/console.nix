{ pkgs, ... }:

{
  config = {
    programs = {
      bash.enable = true;
      info.enable = true;
      hstr.enable = true;
    };
    home.packages = with pkgs; [
      git
      git-lfs
      gnupg
      twm
      fzf
      ripgrep
      jq
      fx
      nix-output-monitor
      nixpkgs-fmt
      deadnix
      nix-diff
      nix-tree
      nix-health
    ]
    ++ (if stdenv.isLinux then [ ncdu ] else [ ])
    ++ (if stdenv.isDarwin then [ ] else [ ]);
  };
}
