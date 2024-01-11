{pkgs, ...}:
pkgs.writeShellApplication {
  name = "git-sync";
  runtimeInputs = with pkgs; [git];
  text = ''
    git fetch --all --prune --tags --progress --verbose
    git lfs fetch --all --prune
    git pull --ff-only --tags --progress --verbose
    git status --show-stash --verbose
  '';
}
