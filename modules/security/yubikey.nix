{
  config,
  lib,
  pkgs,
  ...
}:

let
  isGraphical =
    config.display.gnome.enable || config.display.niri.enable || config.display.driftwm.enable;
in

{
  options.security.yubikey.enable = lib.mkEnableOption "Yubikey support" // { default = true; };

  config = lib.mkIf config.security.yubikey.enable {
    # Enable pcscd daemon for smartcard mode (required for GPG/PIV/etc.)
    services.pcscd.enable = lib.mkDefault true;

    # Enable udev rules for Yubikey personalization and access
    services.udev.packages = [ pkgs.yubikey-personalization ];

    # Lock session on Yubikey removal (unless on WSL)
    services.udev.extraRules = lib.mkIf (!config.wsl.enable) ''
      ACTION=="remove",\
       ENV{ID_BUS}=="usb",\
       ENV{ID_MODEL_ID}=="0407",\
       ENV{ID_VENDOR_ID}=="1050",\
       ENV{ID_VENDOR}=="Yubico",\
       RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
    '';

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
      settings = {
        cue = lib.mkDefault true; # Prompt user to touch the Yubikey (e.g. "Please touch the device.")
      };
    };

    # Enable U2F authentication for standard system authorization paths
    security.pam.services = {
      login.u2fAuth = lib.mkDefault true;
      sudo.u2fAuth = lib.mkDefault true;
      systemd-run0.u2fAuth = lib.mkDefault true;
      gdm-password.u2fAuth = lib.mkIf (config.display.gnome.enable && !config.wsl.enable) (
        lib.mkDefault true
      );
    };
  };
}
