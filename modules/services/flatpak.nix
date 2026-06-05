{
  lib,
  config,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.services.flatpak.enable {
    # Systemd service to add Flathub repository at boot
    systemd.services.flatpak-repo = lib.mkDefault {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      '';
    };

    # Systemd service and timer to update Flatpak apps daily
    systemd.services.flatpak-update = lib.mkDefault {
      description = "Update Flatpak applications";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak update -y
      '';
    };

    systemd.timers.flatpak-update = lib.mkDefault {
      description = "Timer to update Flatpak applications daily";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };

    environment.systemPackages = with pkgs; [
      flatpak
      bazaar
    ];

    systemd.packages = with pkgs; [
      flatpak
      bazaar
    ];
  };
}
