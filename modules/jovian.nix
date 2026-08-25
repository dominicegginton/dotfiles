{
  config,
  lib,
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
    services.displayManager.sddm.enable = lib.mkForce false;

    # Enable RTKit and Bluetooth support
    security.rtkit.enable = lib.mkDefault true;
    hardware.bluetooth.enable = lib.mkDefault true;

    # Enable Nix Distributed Build client
    services.nix-builder.client.enable = lib.mkDefault true;

    # Persistent storage for Jovian SteamOS and Decky Loader data
    environment.persistence."/persist" = lib.mkIf config.impermanence.enable {
      directories = [ "/var/lib/decky-loader" ];
      users.dom.directories = [
        ".steam"
        ".local/share/Steam"
        ".local/share/decky-loader"
        ".var/app/com.valvesoftware.Steam"
      ];
    };
  };
}
