{pkgs, ...}: {
  programs = {
    zsh.enable = true;
    bash.enable = true;
  };

  environment.systemPackages = with pkgs; [
    git
    pinentry_mac
    rebuild-darwin
    network-filters-disable
    network-filters-enable
  ];
}
