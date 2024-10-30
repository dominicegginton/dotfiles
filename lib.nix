{ inputs, outputs, stateVersion }:

let
  pkgsFor = platform: outputs.packages.${platform};
  specialArgsFor = hostname: { inherit inputs outputs stateVersion hostname; };
in

with inputs.nixpkgs.lib;
with inputs.nix-darwin.lib;
with inputs.home-manager.lib;

rec {
  mkStringsOption = default: lib.mkOption { inherit default; type = lib.types.listOf lib.types.str; };
  mkAttrsOption = default: lib.mkOption { inherit default; type = lib.types.attrs; };
  packagesFrom = module: { system }: module.packages.${system};
  defaultPackageFrom = module: attrs @ { system }: (packagesFrom module attrs // { inherit system; }).default;

  mkNixosHost = { hostname, platform ? "x86_64-linux" }:

    nixosSystem {
      pkgs = pkgsFor platform;
      specialArgs = specialArgsFor hostname;
      modules = [
        ./hosts/nixos
        ./hosts/nixos/${hostname}
      ];
    };

  mkDarwinHost = { hostname, username, platform ? "x86_64-darwin" }:

    darwinSystem {
      pkgs = pkgsFor platform;
      specialArgs = specialArgsFor hostname // { inherit username; };
      modules = [
        ./hosts/darwin
        ./hosts/darwin/${hostname}
      ];
    };

  mkHome = { hostname, username, platform ? "x86_64-linux" }:

    homeManagerConfiguration {
      pkgs = pkgsFor platform;
      modules = [ ./home ];
      extraSpecialArgs = specialArgsFor hostname // { inherit username; };
    };
}
