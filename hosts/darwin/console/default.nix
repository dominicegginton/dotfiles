{pkgs, ...}: {
  imports = [./zsh.nix];

  programs.bash.enable = true;

  environment.systemPackages = with pkgs; [
    git
    git-lfs
    pinentry_mac
    workspace.network-filters-disable
    workspace.network-filters-enable
  ];
}
