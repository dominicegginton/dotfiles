{
  self,
  config,
  lib,
  pkgs,
  ...
}:

{
  system = {
    # NixOS state version (enforced for system compatibility)
    stateVersion = lib.mkForce config.system.nixos.release;

    # Enforce branding for all systems
    nixos = {
      distroName = lib.mkForce "Residence"; # Branding: always "Residence"
      distroId = lib.mkForce "residence"; # Branding: always "residence"
      vendorName = lib.mkForce self.outputs.lib.maintainers.dominicegginton.name; # Branding
      vendorId = lib.mkForce self.outputs.lib.maintainers.dominicegginton.github; # Branding
      tags = lib.mkForce [
        (lib.optionalString (pkgs.stdenv.isLinux) "residence-linux")
        (lib.optionalString config.wsl.enable "wsl")
      ];
    };
  };
}
