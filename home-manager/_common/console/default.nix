{pkgs, ...}: {
  imports = [
    ./zsh.nix
    ./tmux.nix
    ./git.nix
    ./neovim.nix
    ./gh.nix
  ];

  programs.bash.enable = true;
  programs.info.enable = true;
  programs.hstr.enable = true;

  home.packages = with pkgs; [
    workspace.rebuild-home
    neofetch
    htop-vim
    bottom
  ];
}
