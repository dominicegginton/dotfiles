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
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-topology.url = "github:oddlama/nix-topology";
    nix-topology.inputs.nixpkgs.follows = "nixpkgs";
    nix-github-actions.url = "github:nix-community/nix-github-actions";
    nix-github-actions.inputs.nixpkgs.follows = "nixpkgs";
    ags.url = "github:aylur/ags?rev=3ed9737bdbc8fc7a7c7ceef2165c9109f336bff6";
    ags.inputs.nixpkgs.follows = "nixpkgs";
    vulnix.url = "github:nix-community/vulnix";
    vulnix.inputs.nixpkgs.follows = "nixpkgs";
    base16.url = "github:SenchoPens/base16.nix";
    niri.url = "github:yalter/niri?rev=b7909dbf61c7c1511b9a51ef46e1d503d5ba3d05";
    niri.inputs.nixpkgs.follows = "nixpkgs";
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
    firefox-gnome-theme.url = "github:rafaelmardojai/firefox-gnome-theme";
    firefox-gnome-theme.flake = false;
  };

  nixConfig = {
    experimental-features = [
      "configurable-impure-env"
      "nix-command"
      "flakes"
      "pipe-operators"
    ];
    fallback = true;
    warn-dirty = true;
    keep-going = true;
    keep-outputs = true;
    keep-derivations = true;
    auto-optimise-store = true;
    builders-use-substitutes = true;
    substituters = [
      "https://cache.nixos.org"
      "https://dominicegginton-dotfiles.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "dominicegginton-dotfiles.cachix.org-1:gm9nclRacSnrdXSPqXso3Abg2TTuo3PrGUJFGlhAzDU="
    ];
  };

  outputs = { self, nixpkgs, nix-github-actions, ... }:

    let
      lib = import ./lib.nix { inherit (self) inputs outputs; inherit nixConfig; };
      overlays = import ./overlays.nix { inherit (self) inputs outputs; };
      templates = import ./templates { };
    in

    with nixpkgs.lib;
    with nix-github-actions.lib;
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
              niri.overlays.default
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
          buildAndCachePackages = {
            inherit (pkgs) residence niri neovim bws twm tailscale residence-iso;
            inherit (pkgs.bleeding) sherlock-launcher;
          };
          devShells = {
            default = pkgs.callPackage ./shell.nix { };
            nodejs = pkgs.callPackage ./shells/nodejs.nix { };
            python3 = pkgs.callPackage ./shells/python3.nix { };
            python3-notebook = pkgs.callPackage ./shells/python3-notebook.nix { };
          };
          topology = import self.inputs.nix-topology {
            inherit pkgs;
            modules = [{ inherit (self) nixosConfigurations; } ./topology.nix];
          };
        })

    //

    {
      inherit lib overlays templates;
      nixosConfigurations = {
        ghost-gs60 = nixosSystem { hostname = "ghost-gs60"; };
        latitude-7390 = nixosSystem { hostname = "latitude-7390"; };
        rio = nixosSystem { hostname = "rio"; };
      };
      darwinConfigurations.MCCML44WMD6T = darwinSystem { hostname = "MCCML44WMD6T"; };
      githubActions = mkGithubMatrix {
        checks =
          nixpkgs.lib.attrsets.recursiveUpdate
            (getAttrs (attrNames githubPlatforms) self.devShells)
            (getAttrs [ "x86_64-linux" ] self.buildAndCachePackages);
      };
    };
}
