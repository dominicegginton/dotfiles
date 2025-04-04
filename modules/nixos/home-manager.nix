{ inputs, theme, pkgs, stateVersion, ... }:

{
  config = {
    environment.systemPackages = [ pkgs.home-manager ];
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.sharedModules = [
      inputs.impermanence.homeManagerModules.impermanence
      inputs.plasma-manager.homeManagerModules.plasma-manager
      inputs.base16.nixosModule
      {
        scheme = "${inputs.tt-schemes}/base16/solarized-${theme}.yaml";
        home.stateVersion = stateVersion;
        home.activation.report-changes = "${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath";
      }
      ../home-manager
    ];
    home-manager.backupFileExtension = "backup";
    home-manager.users = {
      dom = _: {
        imports = [ ../../home/dom ];
        programs.home-manager.enable = true;
      };
    };
  };
}
