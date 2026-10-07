{
  lib,
  platform,
  pkgs,
  ...
}:

{
  disabledModules = [
    "nixos/modules/security/sudo.nix"
  ];

  # Set host platform
  nixpkgs.hostPlatform = lib.mkDefault platform;

  environment.systemPackages = with pkgs; [
    acli
    sonar-scanner-cli
    cursor-cli
    jetbrains.gateway
    nodejs
    typescript
  ];

  # Enable WSL compatibility
  wsl = {
    enable = true;
    defaultUser = "dom";
    nvidia.enable = true;
    wrappedShell.enable = true;
  };

  # Disable Tailscale on WSL by default as blocked by host environment
  services.tailscale.enable = lib.mkForce false;
  services.tsnsrv.enable = lib.mkForce false;

  # Enable containerization support via Docker
  virtualisation.docker.enable = true;

  # Topology information
  topology.self.hardware.info = "Windows Subsystem for Linux - GuestOf MCCLT5CG53030HM";
}
