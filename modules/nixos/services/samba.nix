{ config, lib, ... }:

let
  cfg = config.modules.services.samba;
in

with lib;

{
  options.modules.services.samba.enable = mkEnableOption "samba";

  config = mkIf cfg.enable {
    services.samba.enable = true;
  };
}
