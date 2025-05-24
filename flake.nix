rec {
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-bleeding.url = "github:nixos/nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-images.url = "github:nix-community/nixos-images";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    nixpkgs-wayland.inputs.nixpkgs.follows = "nixpkgs";
    vulnix.url = "github:nix-community/vulnix";
    vulnix.inputs.nixpkgs.follows = "nixpkgs";
    base16.url = "github:SenchoPens/base16.nix";
    tt-schemes.url = "github:tinted-theming/schemes";
    tt-schemes.flake = false;
    base16-vim.url = "github:tinted-theming/base16-vim";
    base16-vim.flake = false;
    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly.inputs.nixpkgs.follows = "nixpkgs";
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

  nixConfig = {
    experimental-features = [
      "auto-allocate-uids"
      "configurable-impure-env"
      "nix-command"
      "flakes"
      "pipe-operators"
    ];
    fallback = true;
    warn-dirty = true;
    keep-going = true;
    keep-outputs = false;
    keep-derivations = false;
    auto-optimise-store = true;
    builders-use-substitutes = true;
    substituters = [
      "https://cache.nixos.org"
      "https://dominicegginton.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "dominicegginton.cachix.org-1:P8AQ3itMEVevMqAzCKiPyvJ6l1a9NVaFPAXJqb9mAaY="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
  };

  outputs = { self, nixpkgs, ... }:

    let
      lib = import ./lib.nix { inherit (self) inputs outputs; inherit nixConfig; };
      overlays = import ./overlays.nix { inherit (self) inputs outputs; };
      templates = import ./templates { };
    in

    with nixpkgs.lib;
    with lib;

    eachPlatform platforms.all
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
            overlays = with self.inputs; [
              overlays.default
              overlays.unstable
              overlays.bleeding
              nixpkgs-wayland.overlays.default
              neovim-nightly.overlays.default
              flip.overlays.default
              roll.overlays.default
              nix-topology.overlays.default
              nix-topology.overlays.topology
            ];
          };
        in

        {
          formatter = pkgs.unstable.nixpkgs-fmt;
          legacyPackages = pkgs;
          devShells.default = pkgs.callPackage ./shell.nix { };
          devShells.nodejs = pkgs.callPackage ./shells/nodejs.nix { };
          devShells.python3 = pkgs.callPackage ./shells/python3.nix { };
          topology = import self.inputs.nix-topology { inherit pkgs; modules = [{ inherit (self) nixosConfigurations; } ./topology.nix]; };
        })

    //

    {
      inherit lib overlays templates;
      nixosConfigurations.nixos-installer = nixosSystem { hostname = "nixos-installer"; };
      nixosConfigurations.ghost-gs60 = nixosSystem { hostname = "ghost-gs60"; };
      nixosConfigurations.latitude-5290 = nixosSystem { hostname = "latitude-5290"; };
      nixosConfigurations.latitude-7390 = nixosSystem { hostname = "latitude-7390"; };
      darwinConfigurations.MCCML44WMD6T = darwinSystem { hostname = "MCCML44WMD6T"; };
    };
}
