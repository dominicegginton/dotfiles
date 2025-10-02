{ pkgs, config, lib, ... }:

{
  config = lib.mkIf config.programs.steam.enable {
    boot.kernel.sysctl."net.ipv4.tcp_mtu_probing" = true; # See: https://github.com/ValveSoftware/SteamOS/issues/1006
    environment.systemPackages = [ pkgs.gamescope ];
    hardware = {
      steam-hardware.enable = true;
      xone.enable = true;
      graphics = {
        enable = true;
        extraPackages = [ pkgs.gamescope-wsi ];
        extraPackages32 = [ pkgs.pkgsi686Linux.gamescope-wsi ];
      };
    };
    programs = {
      steam.gamescopeSession.enable = true;
      xwayland.enable = true;
      gamescope = {
        enable = true;
        capSysNice = true;
      };
    };
    services = {
      pulseaudio.support32Bit = true;
      displayManager.enable = true;
      udev.extraRules = ''
        # USB devices and topological children
        SUBSYSTEMS=="usb", TAG+="uaccess"

        # HID devices over hidraw
        KERNEL=="hidraw*", TAG+="uaccess"

        # Steam Controller udev write access
        KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"
      '';
    };
    # allow users in 'users' group to manage network connections
    # from within the steam deck user interface
    security.polkit.extraConfig = ''
      // residence: Allow users to configure Wi-Fi in Deck UI
      polkit.addRule(function(action, subject) {
        if (
          action.id.indexOf("org.freedesktop.NetworkManager") == 0 &&
          subject.isInGroup("users") &&
          subject.local &&
          subject.active
        ) {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
