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

  nixpkgs.hostPlatform = lib.mkDefault platform;

  environment.systemPackages = with pkgs; [
    acli
    sonar-scanner-cli
    cursor-cli
    jetbrains.gateway
    nodejs
    typescript
  ];

  wsl = {
    enable = true;
    defaultUser = "dom";
    nvidia.enable = true;
    wrappedShell.enable = true;
  };

  services.tailscale.enable = lib.mkForce false;
  services.tsnsrv.enable = lib.mkForce false;

  virtualisation.docker.enable = true;

  topology.self.hardware.info = "Windows Subsystem for Linux - GuestOf MCCLT5CG53030HM";
}
