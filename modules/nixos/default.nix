{ modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
    ./backup.nix
    ./bluetooth.nix
    ./calmav.nix
    ./environment.nix
    ./filesystem.nix
    ./frigate.nix
    ./gnome.nix
    ./home-assistant.nix
    ./mosquitto.nix
    ./networking.nix
    ./residence.nix
    ./roles.nix
    ./secrets.nix
    ./silverbullet.nix
    ./steam.nix
    ./unifi.nix
    ./upgrade.nix
    ./users.nix
    ./virtualisation.nix
    ./wio.nix
    ./zabbix.nix
  ];

  ## todo: tidy up
  boot = {
    consoleLogLevel = 0;
    initrd.verbose = false;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
  security = {
    sudo.enable = true;
    polkit.enable = true;
  };
  services = {
    dbus.enable = true;
    smartd.enable = true;
    thermald.enable = true;
    power-profiles-daemon.enable = true;
    upower.enable = true;
  };

}
