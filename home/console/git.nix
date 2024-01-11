{pkgs, ...}: {
  programs.git.enable = true;

  home.packages = with pkgs; [git-lfs workspace.git-sync];
}
