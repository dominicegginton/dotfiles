{ self, lib, pkgs, ... }:

{
  config.system = {
    autoUpgrade = {
      enable = true;
      dates = "02:00";
      flake = "github:${self.outputs.lib.maintainers.dominicegginton.github}/dotfiles";
      operation = "switch";
      persistent = true;
    };
    activationScripts.upgrade.text = ''
      if [[ -e /run/current-system ]]; then
        ${lib.getExe pkgs.nvd} --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
      fi
    '';
  };
}
