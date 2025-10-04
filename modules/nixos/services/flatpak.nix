{ lib, config, pkgs, ... }:

{
  config.systemd.services.flatpak-repo = lib.mkIf config.services.flatpak.enable {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
}
