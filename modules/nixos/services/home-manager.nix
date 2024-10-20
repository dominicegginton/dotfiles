{ inputs, pkgs, ... }:

{
  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
    environment.systemPackages = [ pkgs.home-manager ];
  };
}
