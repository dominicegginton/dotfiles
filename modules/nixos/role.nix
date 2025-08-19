{ config, lib, ... }:

{
  options.role = lib.mkOption {
    type = lib.types.enum [ "server" "workstation" "kiosk" "bigscreen" "console" "installer" ];
    description = "Machine role configuration.";
  };

  config = {
    topology.self.deviceType = lib.mkDefault "residence-${config.role}";
  };
}
