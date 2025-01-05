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

  mkNixosInstaller = { hostname, platform ? "x86_64-linux" }:
    nixosSystem {
      pkgs = pkgsFor platform;
      specialArgs = specialArgsFor hostname;
      modules = [ ./hosts/nixos/nixos-installer.nix ];
    };

  mkNixosHost = { hostname, platform ? "x86_64-linux" }:
    nixosSystem {
      pkgs = pkgsFor platform;
      specialArgs = specialArgsFor hostname;
      modules = with inputs; [
        disko.nixosModules.disko
        home-manager.nixosModules.default
        base16.nixosModule
        juvian.nixosModules.default
        impermanence.nixosModules.impermanence
        (if hostname == "nixos-installer" then ./hosts/nixos/nixos-installer.nix else ./hosts/nixos/${hostname})
        ./modules/nixos
        {
          scheme = "${inputs.tt-themes}/base16/solarized-${theme}.yaml";
          home-manager.extraSpecialArgs = specialArgsFor hostname;
        }
      ];
    };

  mkDarwinHost = { hostname, platform ? "x86_64-darwin" }:
    darwinSystem {
      pkgs = pkgsFor platform;
      specialArgs = specialArgsFor hostname;
      modules = [
        ./hosts/darwin/${hostname}.nix
        ./modules/darwin
        {
          scheme = "${inputs.tt-themes}/base16/solarized-${theme}.yaml";
          home-manager.extraSpecialArgs = specialArgsFor hostname;
        }
      ];
    };
}
