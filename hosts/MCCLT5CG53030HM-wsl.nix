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
  environment.sessionVariables.VSCODE_SKIP_SERVER_REQUIREMENTS_CHECK = "1";

  # Enable Docker integration
  virtualisation.docker.enable = true;

  # Disable Tailscale on WSL as blocked by host environment
  services.tailscale.enable = lib.mkForce false;

  # Topology information
  topology.self.hardware.info = "Windows Subsystem for Linux - GuestOf MCCLT5CG53030HM";
}
