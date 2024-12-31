{ inputs, outputs, stateVersion, theme }:

let
  pkgsFor = platform: outputs.legacyPackages.${platform};
  specialArgsFor = hostname: { inherit inputs outputs stateVersion hostname theme; };
  sharedModule = hostname: {
    scheme = "${inputs.tt-schemes}/base16/solarized-${theme}.yaml";
    home-manager.extraSpecialArgs = specialArgsFor hostname;
  };
in

with inputs.nixpkgs.lib;
with inputs.nix-darwin.lib;
with inputs.home-manager.lib;

rec {
  packagesFrom = module: { system }: module.packages.${system};
  defaultPackageFrom = module: attrs @ { system }: (packagesFrom module attrs // { inherit system; }).default;

  mkNixosIso = { hostname, platform ? "x86_64-linux" }:
    nixosSystem {
      pkgs = pkgsFor platform;
      specialArgs = specialArgsFor hostname;
      modules = [ ./hosts/nixos/minimal-iso.nix ];
    };

  mkNixosHost = { hostname, platform ? "x86_64-linux" }:
    nixosSystem {
      pkgs = pkgsFor platform;
      specialArgs = specialArgsFor hostname;
      modules = [
        inputs.juvian.nixosModules.default
        inputs.impermanence.nixosModules.impermanence
        inputs.disko.nixosModules.disko
        inputs.home-manager.nixosModules.default
        inputs.base16.nixosModule
        ./hosts/nixos/${hostname}
        ./modules/nixos
        (sharedModule hostname)
      ];
    };

  mkDarwinHost = { hostname, platform ? "x86_64-darwin" }:
    darwinSystem {
      pkgs = pkgsFor platform;
      specialArgs = specialArgsFor hostname;
      modules = [
        ./hosts/darwin/${hostname}.nix
        ./modules/darwin
        (sharedModule hostname)
      ];
    };
}
