{ modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
    ./display/gnome.nix
    ./display/niri.nix
    ./display/steamos.nix
    ./hardware/bluetooth.nix
    ./programs/alacritty.nix
    ./programs/chromium.nix
    ./programs/firefox.nix
    ./programs/sherlock-launcher.nix
    ./programs/steam.nix
    ./programs/vscode.nix
    ./programs/zsh.nix
    ./services/calmav.nix
    ./services/flatpak.nix
    ./services/frigate.nix
    ./services/home-assistant.nix
    ./services/mosquitto.nix
    ./services/pipewire.nix
    ./services/silverbullet.nix
    ./services/tailscale.nix
    ./services/tlp.nix
    ./services/unifi.nix
    ./services/zabbix.nix
    ./virtualisation/virtualisation.nix
    ./virtualisation/docker.nix
    ./virtualisation/waydroid.nix
    ./backup.nix
    ./console.nix
    ./environment.nix
    ./filesystem.nix
    ./networking.nix
    ./secrets.nix
    ./upgrade.nix
    ./users.nix
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
  hardware.system76.power-daemon.enable = true;
  services = {
    dbus.enable = true;
    smartd.enable = true;
    thermald.enable = true;
    upower.enable = true;
  };
}
