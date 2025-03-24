{ inputs, outputs, stateVersion, theme, tailnet }:

let
  pkgsFor = platform: outputs.legacyPackages.${platform};
  specialArgsFor = hostname: { inherit inputs outputs stateVersion hostname theme tailnet; };
in

with inputs.nixpkgs.lib;
with inputs.nix-darwin.lib;
with inputs.home-manager.lib;

rec {
  packagesFrom = module: { system }: module.packages.${system};
  defaultPackageFrom = module: attrs @ { system }: (packagesFrom module attrs // { inherit system; }).default;

  mkNixosHost = { hostname, platform ? "x86_64-linux" }:
    nixosSystem {
      pkgs = pkgsFor platform;
      specialArgs = specialArgsFor hostname;
      modules = with inputs; [
        base16.nixosModule
        disko.nixosModules.disko
        impermanence.nixosModules.impermanence
        home-manager.nixosModules.default
        inputs.nix-topology.nixosModules.default
        ./modules/nixos/console.nix
        ./modules/nixos/nix-settings.nix
        (if hostname == "nixos-installer" then ./hosts/nixos/nixos-installer.nix else ./modules/nixos/system.nix)
        (if hostname == "nixos-installer" then ./hosts/nixos/nixos-installer.nix else ./hosts/nixos/${hostname})
        (if hostname == "nixos-installer" then ./hosts/nixos/nixos-installer.nix else ./modules/nixos)
        {
          scheme = "${inputs.tt-schemes}/base16/solarized-${theme}.yaml";
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
          scheme = "${inputs.tt-schemes}/base16/solarized-${theme}.yaml";
          home-manager.extraSpecialArgs = specialArgsFor hostname;
        }
      ];
    };
}
