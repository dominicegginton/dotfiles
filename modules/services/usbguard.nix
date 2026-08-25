{
  lib,
  config,
  pkgs,
  ...
}:

let
  notWSL = !config.wsl.enable;
in

{
  config = lib.mkIf notWSL {
    services.usbguard = {
      enable = lib.mkDefault true;
      presentControllerPolicy = lib.mkDefault "allow";
      dbus.enable = lib.mkDefault true;
      IPCAllowedGroups = lib.mkDefault [
        "usbguard"
        "wheel"
      ];
      rules = "''$(builtins.readFile config.sops.secrets.\"services/usbguard/rules\".path)";
    };
  };
}
