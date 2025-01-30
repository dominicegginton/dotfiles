{ config, lib, ... }:

let
  cfg = config.modules.services.deluge;
in

with lib;

{
  options.modules.services.deluge = {
    enable = mkEnableOption "deluge";
    dataDir = mkOption { type = types.path; };
  };

  config = mkIf cfg.enable {
    modules.secrets.deluge = "225fcfe8-3c90-4513-bd6d-b26800a12bbe";
    services.deluge = {
      enable = true;
      openFirewall = true;
      dataDir = cfg.dataDir;
      web.enable = true;
      web.openFirewall = true;
      declarative = true;
      authFile = "/run/bitwarden-secrets/deulge";
    };
  };
}
