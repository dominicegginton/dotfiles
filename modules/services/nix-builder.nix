{
  config,
  lib,
  pkgs,
  tailnet,
  ...
}:

let
  cfg = config.services.nix-builder;
in

{
  options.services.nix-builder = {
    enable = lib.mkEnableOption "Nix distributed build server";
    client = {
      enable = lib.mkEnableOption "Nix distributed build client";
    };
    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "SSH public keys for the nix-builder user.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      users.users.nix-builder = {
        isNormalUser = true;
        description = "Nix remote builder user";
        openssh.authorizedKeys.keys = cfg.authorizedKeys;
      };
    })

    (lib.mkIf cfg.client.enable {
      nix = {
        distributedBuilds = true;
        buildMachines = [
          {
            hostName = "ghost-gs60.${tailnet}";
            sshUser = "nix-builder";
            sshKey = "/home/dom/.ssh/id_build_key"; # Dedicated build key on client
            systems = [ "x86_64-linux" "aarch64-linux" ];
            maxJobs = 4;
            supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
          }
        ];
      };
    })
  ];
}
