{ self }:

rec {
  tailnet = "soay-puffin.ts.net";
  nixosHostnames = self.inputs.nixpkgs.lib.attrNames self.outputs.nixosConfigurations;
  darwinHostnames = self.inputs.nixpkgs.lib.attrNames self.outputs.darwinConfigurations;
  hostnames = nixosHostnames ++ darwinHostnames;
  maintainers = self.inputs.nixpkgs.lib.maintainers // {
    dominicegginton = {
      name = "Dominic Egginton";
      email = "dominic.egginton@gmail.com";
      github = "dominicegginton";
      githubId = 28626241;
      sshKeys = [ "ssh-rsa4096/4C79CE4F82847A9F" ];
    };
  };
  eachPlatformMerge =
    op: platforms: f:
    builtins.foldl' (op f) { } (
      if !builtins ? currentSystem || builtins.elem builtins.currentSystem platforms then
        platforms
      else
        platforms ++ [ builtins.currentSystem ]
    );
  eachPlatform = eachPlatformMerge (
    f: attrs: platform:
    let
      ret = f platform;
    in
    builtins.foldl' (
      attrs: key:
      attrs
      // {
        ${key} = (attrs.${key} or { }) // {
          ${platform} = ret.${key};
        };
      }
    ) attrs (builtins.attrNames ret)
  );
  packagesFrom = module: platform: module.packages.${platform};
  nixosSystem =
    {
      hostname,
      platform ? "x86_64-linux",
      modules ? [ ],
      ...
    }:
    self.inputs.nixpkgs.lib.nixosSystem {
      pkgs = self.outputs.nixpkgsFor.${platform};
      specialArgs = {
        inherit
          self
          tailnet
          hostname
          platform
          ;
      };
      modules =
        with self.inputs;
        modules
        ++ [
          nix-topology.nixosModules.default
          base16.nixosModule
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.default
          run0-sudo-shim.nixosModules.default
          deadman.nixosModules.default
          ./modules
        ];
    };
}
