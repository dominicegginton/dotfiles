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
