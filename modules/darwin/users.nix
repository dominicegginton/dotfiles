{ inputs, config, lib, ... }:

with lib;

{
  config = {
    home-manager.users = {
      dom = _: {
        imports = [
          inputs.plasma-manager.homeManagerModules.plasma-manager
          inputs.base16.nixosModule
          { scheme = "${inputs.tt-schemes}/base16/solarized-dark.yaml"; }
          ../../modules/home-manager
          ../../home/dom
        ];
      };
    };

    users.users = {
      "dom.egginton" = {
        name = "dom.egginton";
        home = "/Users/dom.egginton";
      };
    };

    home-manager.users = {
      "dom.egginton" = {
        imports = [
          inputs.plasma-manager.homeManagerModules.plasma-manager
          inputs.base16.nixosModule
          { scheme = "${inputs.tt-schemes}/base16/solarized-dark.yaml"; }
          ../../modules/home-manager
          ../../home/dom.egginton
        ];
      };
    };
  };
}
