# TODO: tidy this file:
#        default.nix
#        disks.nix
#        boot.nix
#        harkware.nix

{ inputs, pkgs, config, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.dell-latitude-7390
    ./disks.nix
    ./boot.nix
  ];

  hardware.mwProCapture.enable = true;
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;
  services.logind.extraConfig = "HandlePowerKey=suspend";
  services.logind.lidSwitch = "suspend";

  nix.distributedBuilds = true;
  nix.buildMachines = [{
    hostName = "ghost-gs60";
    system = "x86_64-linux";
    protocol = "ssh-ng";
    # sshKey = config.sops.secrets.ssh-remote-builder.path;
    maxJobs = 1;
    speedFactor = 2;
    systems = [
      "x86_64-linux"
      "i686-linux"
    ];
    maxJobs = 64;
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

  modules = {
    users.dom.enable = true;
    desktop.plasma.enable = true;

    services = {
      virtualisation.enable = true;
      bluetooth.enable = true;
      syncthing.enable = true;

      networking = {
        enable = true;
        hostname = "latitude-7390";
        wireless = true;
      };
    };
  };
}
