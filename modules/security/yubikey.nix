{
  config,
  lib,
  pkgs,
  ...
}:

let
  isGraphical =
    config.display.gnome.enable || config.display.niri.enable || config.display.driftwm.enable;

  topologyContent = builtins.readFile ../../topology.nix;
  homeNetworkKey =
    let
      match = builtins.match ".*#[ \t]*Local home network \\(LAN\\)[ \r\n\t]*([a-zA-Z0-9_-]+)[ \t]*=[ \t]*\\{.*" topologyContent;
    in
    if match != null then builtins.head match else "ribble";

  detectedHomeSsid =
    let
      firstChar = lib.strings.toUpper (builtins.substring 0 1 homeNetworkKey);
      rest = builtins.substring 1 (builtins.stringLength homeNetworkKey) homeNetworkKey;
    in
    firstChar + rest;
in

{
  options.security.yubikey = {
    enable = lib.mkEnableOption "Yubikey support" // {
      default = true;
    };
    homeSsid = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = detectedHomeSsid;
      description = "SSID of trusted Wi-Fi network. Yubikey removal lock will be bypassed when connected to this network.";
    };
  };

  config = lib.mkIf config.security.yubikey.enable {
    # Enable pcscd daemon for smartcard mode (required for GPG/PIV/etc.)
    services.pcscd.enable = lib.mkDefault true;

    # Enable udev rules for Yubikey personalization and access
    services.udev.packages = [ pkgs.yubikey-personalization ];

    # Whitelist Yubikeys in USBGuard
    services.usbguard.extraRules = lib.mkIf config.services.usbguard.enable ''
      allow id 1050:*
    '';

    # Lock session on Yubikey removal (unless on WSL)
    services.udev.extraRules = lib.mkIf (!config.wsl.enable) (
      let
        lockScript = pkgs.writeShellScript "yubikey-lock-session" ''
          if [ -n "${toString (config.security.yubikey.homeSsid != null)}" ]; then
            if ${pkgs.iwd}/bin/iwctl station show | grep -q "Connected network"; then
              CURRENT_SSID=$(${pkgs.iwd}/bin/iwctl station show | grep "Connected network" | awk '{print $3}')
              if [ "$CURRENT_SSID" = "${config.security.yubikey.homeSsid}" ]; then
                exit 0
              fi
            fi
            if command -v nmcli >/dev/null 2>&1; then
              CURRENT_SSID=$(nmcli -t -f ACTIVE,SSID dev wifi | grep "^yes:" | cut -d: -f2)
              if [ "$CURRENT_SSID" = "${config.security.yubikey.homeSsid}" ]; then
                exit 0
              fi
            fi
          fi

          ${pkgs.systemd}/bin/loginctl lock-sessions
        '';
      in
      ''
        ACTION=="remove",\
         ENV{ID_BUS}=="usb",\
         ENV{ID_MODEL_ID}=="0407",\
         ENV{ID_VENDOR_ID}=="1050",\
         ENV{ID_VENDOR}=="Yubico",\
         RUN+="${lockScript}"
      ''
    );

    # Install Yubikey management and configuration utilities
    environment.systemPackages =
      with pkgs;
      [
        yubikey-manager # CLI management tool (ykman)
        yubikey-personalization # CLI personalization tool (ykpersonalize)
        yubico-piv-tool # CLI PIV tool (yubico-piv-tool)
      ]
      ++ lib.optionals isGraphical [
        yubioath-flutter # GUI manager
      ];

    # Configure PAM for FIDO2/U2F authentication
    security.pam.u2f = {
      enable = lib.mkDefault true;
      control = lib.mkDefault "required"; # Enforce U2F authentication for all configured services
      settings = {
        cue = lib.mkDefault true; # Prompt user to touch the Yubikey (e.g. "Please touch the device.")
      };
    };

    # Enable U2F authentication for standard system authorization paths
    security.pam.services = {
      # Lock Screens & Screensavers
      gnome-screensaver.u2fAuth = lib.mkIf config.services.displayManager.gdm.enable (lib.mkDefault true);
      gnome-shell.u2fAuth = lib.mkIf config.services.displayManager.gdm.enable (lib.mkDefault true);
      swaylock.u2fAuth = lib.mkIf config.display.niri.enable (lib.mkDefault true);
      i3lock.u2fAuth = lib.mkIf (config.services.xserver.windowManager.i3.enable or false) (lib.mkDefault true);
      gtklock.u2fAuth = lib.mkIf (config.programs.gtklock.enable or false) (lib.mkDefault true);
      waylock.u2fAuth = lib.mkIf (config.programs.waylock.enable or false) (lib.mkDefault true);
      vlock.u2fAuth = lib.mkDefault true;

      # Identity Elevation 
      sudo.u2fAuth = lib.mkDefault true;
      systemd-run0.u2fAuth = lib.mkDefault true;
      su.u2fAuth = lib.mkDefault true;
      runuser.u2fAuth = lib.mkDefault true;
      polkit-1.u2fAuth = lib.mkIf isGraphical (lib.mkDefault true);

      # Login & Display Managers
      login.u2fAuth = lib.mkDefault true;
      sshd.u2fAuth = lib.mkIf config.services.openssh.enable (lib.mkDefault true);
      gdm-password.u2fAuth = lib.mkIf config.services.displayManager.gdm.enable (lib.mkDefault true);
      gdm-autologin.u2fAuth = lib.mkIf config.services.displayManager.gdm.enable (lib.mkDefault true);
    };
  };
}
