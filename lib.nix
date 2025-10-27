{ inputs, outputs, nixConfig }:

rec {
  tailnet = "soay-puffin.ts.net";
  nixosHostnames = inputs.nixpkgs.lib.attrNames outputs.nixosConfigurations;
  darwinHostnames = inputs.nixpkgs.lib.attrNames outputs.darwinConfigurations;
  hostnames = nixosHostnames ++ darwinHostnames;
  maintainers = inputs.nixpkgs.lib.maintainers // {
    dominicegginton = {
      name = "Dominic Egginton";
      email = "dominic.egginton@gmail.com";
      github = "dominicegginton";
      githubId = 28626241;
      sshKeys = [ "ssh-rsa4096/4C79CE4F82847A9F" ];
    };
  };
  eachPlatformMerge = op: platforms: f: builtins.foldl' (op f) { } (if !builtins ? currentSystem || builtins.elem builtins.currentSystem platforms then platforms else platforms ++ [ builtins.currentSystem ]);
  eachPlatform = eachPlatformMerge (f: attrs: platform: let ret = f platform; in builtins.foldl' (attrs: key: attrs // { ${key} = (attrs.${key} or { }) // { ${platform} = ret.${key}; }; }) attrs (builtins.attrNames ret));
  packagesFrom = module: platform: module.packages.${platform};
  nixosSystem = { hostname, platform ? "x86_64-linux", ... } @attrs:
    inputs.nixpkgs.lib.nixosSystem {
      pkgs = outputs.legacyPackages.${platform};
      specialArgs = {
        inherit inputs outputs tailnet hostname nixConfig;
        dlib = outputs.lib;
      };
      modules = attrs.modules ++ [
        inputs.base16.nixosModule
        inputs.disko.nixosModules.disko
        inputs.impermanence.nixosModules.impermanence
        inputs.nixos-wsl.nixosModules.default
        inputs.home-manager.nixosModules.default
        inputs.nix-topology.nixosModules.default
        ./modules/nixos
      ];
    };
}
