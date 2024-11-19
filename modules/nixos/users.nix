{ inputs, config, lib, pkgs, ... }:

with lib;

{
  config = {
    sops.secrets."dom.password".neededForUsers = true;

     home-manager.users = {
       dom = _: {
        imports = [
          inputs.sops-nix.homeManagerModules.sops
          inputs.plasma-manager.homeManagerModules.plasma-manager
          inputs.base16.nixosModule
          { scheme = "${inputs.tt-schemes}/base16/solarized-dark.yaml"; }
          ../../modules/home-manager
          ../../home/dom
        ];
      };
     };
     users.users = {
      dom = {
        description = "Dominic Egginton";
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets."dom.password".path;
        homeMode = "0755";
        shell = pkgs.zsh;
        extraGroups = [
          "wheel"
          "audio"
          "input"
          "users"
          "video"
          "docker"
        ];
      };

      nixremote = {
        description = "Nix Remote";
        isNormalUser = mkDefault true;
        home = mkForce "/var/empty";
        extraGroups = [ "nixremote" ];
      };

      root = {
        description = "System administrator";
        isNormalUser = mkDefault false;
        hashedPassword = mkDefault null;
      };
    };
  };
}
