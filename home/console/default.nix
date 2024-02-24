{pkgs, ...}: {
  imports = [
    ./zsh.nix
    ./tmux.nix
    ./git.nix
    ./neovim.nix
    ./gh.nix
    ./lf.nix
  ];

  programs.bash.enable = true;
  programs.info.enable = true;
  programs.hstr.enable = true;

  home.packages = with pkgs; [rebuild-home];
}
