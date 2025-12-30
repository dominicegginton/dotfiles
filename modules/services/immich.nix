{ config, lib, pkgs, hostname, ... }:

{
  config = lib.mkIf config.services.immich.enable {
    services.immich.host = "0.0.0.0";

    services.nginx = {
      enable = true;
      virtualHosts."immich.${hostname}" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://localhost:${toString 2283}";
      };
    };

    systemd.services."immich-gcs-mount" = {
      description = "Mount GCS bucket for Immich data";
      after = [ "network-online.target" "decrypt-secrets.service" ];
      requires = [ "decrypt-secrets.service" ];
      before = [ "immich.service" ];
      wantedBy = [ "immich.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        ExecStart = ''
          echo "Mounting GCS bucket for Immich data..."
        '';
        ExecStop = ''
          echo "Unmounting GCS bucket for Immich data..."
        '';
      };
    };
  };
}

