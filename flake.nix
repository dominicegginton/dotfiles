{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-images.url = "github:nix-community/nixos-images";
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    nixos-anywhere.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    vulnix.url = "github:nix-community/vulnix";
    base16.url = "github:SenchoPens/base16.nix";
    tt-schemes.url = "github:tinted-theming/schemes";
    tt-schemes.flake = false;
    base16-vim.url = "github:tinted-theming/base16-vim";
    base16-vim.flake = false;
    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    twm.url = "github:vinnymeller/twm";
    twm.inputs.nixpkgs.follows = "nixpkgs";
    todo.url = "github:dominicegginton/todo";
    todo.inputs.nixpkgs.follows = "nixpkgs";
    flip.url = "github:dominicegginton/flip";
    flip.inputs.nixpkgs.follows = "nixpkgs";
    roll.url = "github:dominicegginton/roll";
    roll.inputs.nixpkgs.follows = "nixpkgs";
    nix-topology.url = "github:oddlama/nix-topology";
    nix-topology.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];

  outputs = { self, nixpkgs, ... }:

    let
      inherit (self) inputs outputs;
      stateVersion = "24.05";
      theme = "dark";
      tailnet = "soay-puffin.ts.net";
      lib = import ./lib.nix { inherit inputs outputs stateVersion theme tailnet; inherit (nixpkgs) lib; };
      overlays = import ./overlays.nix { inherit inputs outputs; };
      templates = import ./templates { };
    in

    with lib;

    eachPlatform nixpkgs.lib.platforms.all
      (platform:

        let
          pkgs = import nixpkgs {
            system = platform;
            hostPlatform = platform;
            config = {
              joypixels.acceptLicense = true;
              nvidia.acceptLicense = true;
              allowUnfree = true;
              allowBroken = true;
            };
            overlays = with inputs; [
              overlays.default
              overlays.unstable
              flip.overlays.default
              roll.overlays.default
              nix-topology.overlays.default
              nix-topology.overlays.topology
            ];
          };
        in

        {
          formatter = pkgs.nixpkgs-fmt;
          legacyPackages = pkgs;
          devShells.default = pkgs.callPackage ./shell.nix { };
          devShells.nodejs = pkgs.callPackage ./shells/nodejs.nix { };
          devShells.python = pkgs.callPackage ./shells/python.nix { };
          topology = import inputs.nix-topology {
            inherit pkgs;
            modules = [
              ./topology.nix
              { inherit (self) nixosConfigurations; }
            ];
          };
        })

    //

    {
      inherit lib overlays templates;
      nixosConfigurations.nixos-installer = nixosSystem { hostname = "nixos-installer"; };
      nixosConfigurations.ghost-gs60 = nixosSystem { hostname = "ghost-gs60"; };
      nixosConfigurations.latitude-5290 = nixosSystem { hostname = "latitude-5290"; };
      nixosConfigurations.latitude-7390 = nixosSystem { hostname = "latitude-7390"; };
      darwinConfigurations.MCCML44WMD6T = mkDarwinHost { hostname = "MCCML44WMD6T"; };
    };
}
