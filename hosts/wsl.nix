{
  self,
  lib,
  config,
  platform,
  ...
}:

{
  # Set host platform (default from `platform`)
  nixpkgs.hostPlatform = lib.mkDefault platform;

  # Enable WSL support
  wsl.enable = true;

  # Enable Docker support in WSL
  virtualisation.docker.enable = true;

  topology.self.hardware.info = "Windows Subsystem for Linux";
}
