{pkgs, ...}: {
  imports = [./zsh.nix];

  programs.bash.enable = true;

  environment.systemPackages = with pkgs; [
    git
    git-lfs
    pinentry_mac
    rebuild-host
    rebuild-home
    network-filters-disable
    network-filters-enable
  ];
}
