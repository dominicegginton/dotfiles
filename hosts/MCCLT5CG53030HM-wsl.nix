{
  lib,
  platform,
  ...
}:

{
  # Set host platform
  nixpkgs.hostPlatform = lib.mkDefault platform;

  # Enable WSL compatibility
  wsl.enable = true;
  wsl.nvidia.enable = true;
  wsl.wrappedShell.enable = false;

  # Disable Tailscale on WSL by default as blocked by host environment
  services.tailscale.enable = lib.mkForce false;
  services.tsnsrv.enable = lib.mkForce false;

  # Enable containerization support via Docker
  virtualisation.docker.enable = true;

  # Topology information
  topology.self.hardware.info = "Windows Subsystem for Linux - GuestOf MCCLT5CG53030HM";
}
