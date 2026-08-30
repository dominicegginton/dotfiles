{
  self,
  lib,
  pkgs,
  ...
}:

{
  system = {
    autoUpgrade = {
      enable = lib.mkForce true;
      dates = lib.mkDefault "weekly";
      flake = lib.mkForce "github:${self.outputs.lib.maintainers.dominicegginton.github}/dotfiles";
      operation = lib.mkForce "switch";
      persistent = lib.mkForce true;
      runGarbageCollection = lib.mkForce true;
    };

    activationScripts.upgrade.text = lib.mkForce ''
      if [[ -e /run/current-system ]]; then
        ${lib.getExe pkgs.nvd} --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
      fi
    '';
  };
}
