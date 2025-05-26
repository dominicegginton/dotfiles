{ pkgs, stateVersion, ... }:

{
  config = {
    system = {
      inherit stateVersion;
      autoUpgrade = {
        enable = true;
        dates = "02:00";
        flake = "github:dominicegginton/dotfiles";
        operation = "switch";
        persistent = true;
      };
      activationScripts.diff.text = ''
        if [[ -e /run/current-system ]]; then
          ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
        fi
      '';
    };
  };
}
