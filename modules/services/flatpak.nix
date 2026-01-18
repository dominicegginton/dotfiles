{ lib, config, pkgs, ... }:

{
  config = lib.mkIf config.services.flatpak.enable {
    systemd.services.flatpak-repo = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      '';
    };

    environment.systemPackages = with pkgs; [ flatpak bazaar ];

    systemd.packages = with pkgs; [ flatpak bazaar ];
  };
}
