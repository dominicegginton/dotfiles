{pkgs, ...}: {
  imports = [./zsh.nix];

  environment.systemPackages = with pkgs; [
    git
    git-lfs
    pinentry
  ];
}
