{ inputs, config, lib, theme, pkgs, stateVersion, ... }:

{
  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.sharedModules = [
      inputs.plasma-manager.homeManagerModules.plasma-manager
      inputs.sops-nix.homeManagerModules.sops
      inputs.plasma-manager.homeManagerModules.plasma-manager
      inputs.base16.nixosModule
      {
        scheme = "${inputs.tt-schemes}/base16/solarized-${theme}.yaml";
        home.file.theme.text = theme;
        home.stateVersion = stateVersion;
        home.activation.report-changes = "${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath";
      }
      ../../home-manager ## todo: refactor
    ];
  };
}
