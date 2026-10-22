{ self
, config
, lib
, pkgs
, ...
}:

{
  system = {
    # NixOS state version (enforced for system compatibility)
    stateVersion = lib.mkForce config.system.nixos.release;

    # Enforce branding for all systems
    nixos = {
      distroName = lib.mkForce "Residence"; # Branding: always "Residence"
      # VS Code's WSL server checks ID rather than ID_LIKE to recognize NixOS.
      distroId = lib.mkForce (if config.wsl.enable then "nixos" else "residence");
      vendorName = lib.mkForce self.outputs.lib.maintainers.dominicegginton.name; # Branding
      vendorId = lib.mkForce self.outputs.lib.maintainers.dominicegginton.github; # Branding
      tags = lib.mkForce [
        (lib.optionalString pkgs.stdenv.hostPlatform.isLinux "residence-linux")
        (lib.optionalString config.wsl.enable "wsl")
      ];
    };
  };
}
