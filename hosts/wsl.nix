{
  self,
  lib,
  config,
  platform,
  ...
}:

{
  # Set host platform
  nixpkgs.hostPlatform = lib.mkDefault platform;

  # Enable WSL compatibility
  wsl.enable = true;

  # Enable Docker integration
  virtualisation.docker.enable = true;

  # Disable Tailscale on WSL as blocked by host environment
  services.tailscale.enable = lib.mkForce false;

  # Topology information
  topology.self.hardware.info = "Windows Subsystem for Linux";
}
