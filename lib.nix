{ inputs, outputs, stateVersion, theme }:

let
  pkgsFor = platform: outputs.legacyPackages.${platform};
  specialArgsFor = hostname: { inherit inputs outputs stateVersion hostname theme; };
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
        inputs.impermanence.nixosModules.impermanence
        inputs.disko.nixosModules.disko
        inputs.home-manager.nixosModules.default
        { home-manager.extraSpecialArgs = specialArgsFor hostname; }
        inputs.base16.nixosModule
        ./hosts/nixos/${hostname}
        ./modules/nixos
      ];
    };

  mkDarwinHost = { hostname, platform ? "x86_64-darwin" }:
    darwinSystem {
      pkgs = pkgsFor platform;
      specialArgs = specialArgsFor hostname;
      modules = [
        ./hosts/darwin/${hostname}
        ./modules/darwin
      ];
    };
}
