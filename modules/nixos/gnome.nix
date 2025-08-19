{ config, lib, pkgs, ... }:

with config.scheme.withHashtag;

let
  background = pkgs.fetchurl {
    url = "https://unsplash.com/photos/wKdWb9j2BIg/download?ixid=M3wxMjA3fDB8MXxhbGx8NjJ8fHx8fHx8fDE3NTU1MTMwNDF8";
    sha256 = "0c4j500hy5xdy1s2vvfpkiy2ikgmr0a6y5vafymsdjmxhacs8gxs";
  };
in

{
  options.display.gnome.enable = lib.mkEnableOption "Gnome";
  config = lib.mkIf config.display.gnome.enable {
    hardware.graphics.enable = true;
    services.printing.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };
    environment.etc."wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = lib.mkIf config.hardware.bluetooth.enable ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
      }
    '';
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    services.gnome.core-apps.enable = false;
    services.gnome.core-developer-tools.enable = false;
    services.gnome.games.enable = false;
    environment.systemPackages = with pkgs; [ gnome-console ];
    environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome-user-docs ];
    programs.dconf.profiles.user.databases = [
      {
        lockAll = true;
        settings = {
          "org/gnome/desktop/interface" = {
            accent-color = "purple";
          };
          "org/gnome/desktop/background" = {
            picture-uri = "file://${background}";
            picture-options = "zoom";
          };
        };
      }
    ];
  };
}
