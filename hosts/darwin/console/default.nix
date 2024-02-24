{pkgs, ...}: {
  imports = [./zsh.nix];

  programs.bash.enable = true;

  environment.systemPackages = with pkgs; [
    git
    git-lfs
    pinentry_mac
    network-filters-disable
    network-filters-enable
  ];
}
