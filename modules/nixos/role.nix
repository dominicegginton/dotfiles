{ config, lib, pkgs, ... }:

{
  ## role option is a enum of "server", "workstation", "kiosk", "bigscreen", "console"
  options.nixos.role = lib.mkOption {
    type = lib.types.enum [
      "server"
      "workstation"
      "kiosk"
      "bigscreen"
      "console"
    ];
    description = "Machine role configuration.";
  };

  config = { };
}
