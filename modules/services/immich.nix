{ config, lib, hostname, pkgs, ... }:

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
        Type = "forking";
        Restart= "always";
        Environment = {
          BUCKET = "immich-data-c3c7e5776e8ad852";
          MOUNT_POINT = "/var/lib/immich";
        };
        ExecStart = ''
          ${pkgs.coreutils}/bin/mkdir -p $MOUNT_POINT 
          ${pkgs.gcsfuse}/bin/gcsfuse $BUCKET $MOUNT_POINT
        '';
        ExecStop = ''
          ${pkgs.fusermount}/bin/fusermount -u $MOUNT_POINT
        '';
      };
    };
  };
}

