{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.jovian.enable = lib.mkEnableOption "Jovian SteamOS environment";

  config = lib.mkIf config.jovian.enable {
    jovian = {
      steam = {
        enable = lib.mkDefault true;
        autoStart = lib.mkDefault true;
        user = lib.mkDefault "dom";
        desktopSession = lib.mkDefault "gnome";
      };
      steamos.useSteamOSConfig = lib.mkDefault true;
      hardware.has.amd.gpu = lib.mkDefault true;
      decky-loader.enable = lib.mkDefault true;
    };

    # Enable GNOME desktop environment (session only, Jovian autoStart handles boot UI)
    display.gnome.enable = lib.mkDefault true;
    services.displayManager.gdm.enable = lib.mkForce false;
    services.displayManager.sddm.enable = lib.mkForce false;

    # Enable RTKit and Bluetooth support
    security.rtkit.enable = lib.mkDefault true;
    hardware.bluetooth.enable = lib.mkDefault true;

    # Enable Nix Distributed Build client
    services.nix-builder.client.enable = lib.mkDefault true;
  };
}
