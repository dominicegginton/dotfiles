{ config, lib, ... }:

let
  cfg = config.modules.services.distributedBuilds;
in

with lib;

{
  options.modules.services.distributedBuilds.enable = mkEnableOption "distributed build";

  config = mkIf cfg.enable {
    nix.distributedBuilds = true;
    nix.buildMachines = [{
      hostName = "ghost-gs60";
      system = "x86_64-linux";
      protocol = "ssh-ng";
      # sshKey = config.sops.secrets.ssh-remote-builder.path;
      maxJobs = 8;
      speedFactor = 2;
      systems = [
        "x86_64-linux"
        "i686-linux"
      ];
      supportedFeatures = [
        "big-parallel"
        "kvm"
        "nixos-test"
      ];
    }];

    # programs.ssh.extraConfig = ''
    #   Host ghost-gs60
    #     User nix
    #     ProxyJump login-tum
    #     HostName ghost-gs60
    #     IdentityFile ${config.sops.secrets.ssh-remote-builder.path}
    # '';

  };
}
