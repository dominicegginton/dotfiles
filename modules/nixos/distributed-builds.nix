{ config, lib, ... }:

let
  cfg = config.modules.services.distributedBuilds;
in

with lib;

{
  options.modules.services.distributedBuilds = {
    enable = mkEnableOption "distributed build";
    buildMachines = mkOption {
      type = types.listOf types.attrs;
      default = [ ];
      example = [
        {
          hostName = "burbage";
          system = "x86_64-linux";
          protocol = "ssh-ng";
          maxJobs = 1;
          speedFactor = 2;
          systems = [ "x86_64-linux" "i686-linux" ];
          supportedFeatures = [ "big-parallel" "kvm" "nixos-test" ];
        }
      ];
      description = ''
        List of build machines to use for distributed builds.
      '';
    };
  };

  config = mkIf cfg.enable {
    nix.distributedBuilds = true;
    nix.extraOptions = "builders-use-substitutes = true";
    nix.buildMachines = cfg.buildMachines;
    programs.ssh.extraConfig = ''
      ${lib.concatStringsSep "\n" (map (machine: ''
        Host ${machine.hostName}
          User nixremote
          IdentityFile /root/.ssh/nixremote
      '') cfg.buildMachines)}
    '';
  };
}
