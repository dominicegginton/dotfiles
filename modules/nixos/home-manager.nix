{ inputs, theme, pkgs, stateVersion, ... }:

{
  config = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [
        inputs.impermanence.homeManagerModules.impermanence
        inputs.plasma-manager.homeManagerModules.plasma-manager
        inputs.base16.nixosModule
        {
          scheme = "${inputs.tt-schemes}/base16/solarized-${theme}.yaml";
          home = {
            inherit stateVersion;
            activation.report-changes = "${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath";
          };
        }
        ../home-manager
      ];
      backupFileExtension = "backup";
    };
    environment.systemPackages = [ pkgs.home-manager ];
  };
}
