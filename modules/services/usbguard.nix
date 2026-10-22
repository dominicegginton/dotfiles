{ lib
, config
, ...
}:

let
  notWSL = !config.wsl.enable;
  hasSopsRules = config.sops.secrets ? "services/usbguard/rules";
in

{
  config = lib.mkIf notWSL {
    sops.secrets."services/usbguard/rules" = {
      owner = "root";
      group = "root";
      mode = "0600";
      path = "/etc/usbguard/rules.conf";
    };

    services.usbguard = {
      enable = lib.mkDefault true;
      presentControllerPolicy = lib.mkDefault "allow";
      dbus.enable = lib.mkDefault true;
      IPCAllowedGroups = lib.mkDefault [
        "usbguard"
        "wheel"
      ];
      # If SOPS rules exist, let USBGuard read from the decrypted SOPS file.
      # Otherwise, fall back to safe baseline rules for bootstrap/recovery.
      rules =
        if hasSopsRules then
          null
        else
          lib.mkDefault ''
            allow with-interface e0:01:01
            allow with-connect-type "hardwired"
            allow id 1d6b:*
            allow with-interface 09:00:00
            allow id 1050:*
          '';
      ruleFile = if hasSopsRules then config.sops.secrets."services/usbguard/rules".path else null;
    };
  };
}
