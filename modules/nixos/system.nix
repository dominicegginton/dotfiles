{ pkgs, stateVersion, ... }:

{
  config = {
    system = {
      inherit stateVersion;
      activationScripts.diff.text = ''
        if [[ -e /run/current-system ]]; then
          ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
        fi
      '';
    };
  };
}
