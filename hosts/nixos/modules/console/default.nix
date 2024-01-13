{pkgs, ...}: {
  imports = [./zsh.nix];

  console = {
    font = "${pkgs.tamzen}/share/consolefonts/TamzenForPowerline10x20.psf";
    keyMap = "uk";
    packages = with pkgs; [tamzen];
  };

  environment.systemPackages = with pkgs; [
    git
    git-lfs
    pinentry
  ];
}
