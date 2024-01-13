# System
#
# System configuration.
{
  pkgs,
  stateVersion,
  ...
}: {
  system = {
    # Scripts to be run at nixos system
    # configuration activation.

    # Diff the current system configuration
    activationScripts.diff = {
      supportsDryActivation = true;
      text = ''
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
      '';
    };

    # State version to be used by nixos-rebuild.
    stateVersion = stateVersion;
  };
}
