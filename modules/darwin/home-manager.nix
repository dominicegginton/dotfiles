{ inputs, config, pkgs, stateVersion, theme, ... }:

{
  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = { inherit theme; };
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

    home-manager.users = {
      "dom.egginton" = _: {
        imports = [ ../../home/dom ];
      };
    };
  };
}
