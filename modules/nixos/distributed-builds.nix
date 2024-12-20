{ config, lib, ... }:

let
  cfg = config.modules.services.distributedBuilds;
in

with lib;

{
  options.modules.services.distributedBuilds.enable = mkEnableOption "distributed build";

  config = mkIf cfg.enable {
    nix.distributedBuilds = true;
    nix.extraOptions = "builders-use-substitutes = true";
    nix.buildMachines = [
      # {
      #   hostName = "ghost-gs60";
      #   system = "x86_64-linux";
      #   protocol = "ssh-ng";
      #   maxJobs = 1;
      #   speedFactor = 2;
      #   systems = [ "x86_64-linux" "i686-linux" ];
      #   supportedFeatures = [ "big-parallel" "kvm" "nixos-test" ];
      # }
      # {
      #   hostName = "burbage";
      #   system = "x86_64-linux";
      #   protocol = "ssh-ng";
      #   maxJobs = 1;
      #   speedFactor = 2;
      #   systems = [ "x86_64-linux" "i686-linux" ];
      #   supportedFeatures = [ "big-parallel" "kvm" "nixos-test" ];
      # }
    ];
    programs.ssh.extraConfig = ''
      # Host ghost-gs60
      #   User nixremote
      #   IdentityFile /root/.ssh/nixremote
      #
      # Host burbage
      #   User nixremote
      #   IdentityFile /root/.ssh/nixremote
    '';
  };
}
