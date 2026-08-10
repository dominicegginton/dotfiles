{
  lib,
  pkgs,
  config,
  ...
}:

{
  # Enable AppArmor for enhanced application isolation, disabled on WSL by default
  security.apparmor = {
    enable = lib.mkForce (!config.wsl.enable);
    # Disable killUnconfinedConfinables as aa-remove-unknown currently has an upstream nixpkgs packaging bug
    killUnconfinedConfinables = lib.mkDefault false;
    enableCache = lib.mkDefault true;
    packages = [ pkgs.apparmor-profiles ];
  };
}
