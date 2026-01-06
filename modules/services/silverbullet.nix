{ config, lib, hostname, pkgs, ... }:

{
  config = lib.mkIf config.services.silverbullet.enable {
    services.silverbullet = {
      listenAddress = "0.0.0.0";
      listenPort = 8765;
      openFirewall = false;
    };

    services.nginx.enable = true;
    services.nginx.virtualHosts."sb.${hostname}" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://${config.services.silverbullet.listenAddress}:${toString config.services.silverbullet.listenPort}";
    };

    systemd.services.silverbullet-gcs-mount = {
      description = "Mount GCS bucket for Silverbullet data";
      after = [ "network-online.target" "decrypt-secrets.service" ];
      requires = [ "decrypt-secrets.service" ];
      before = [ "silverbullet.service" ];
      wantedBy = [ "silverbullet.service" ];
      serviceConfig = {
        Type = "forking";
        Restart= "always";
        Environment = {
          BUCKET = "silverbullet-data-c3c7e5776e8ad852";
          MOUNT_POINT = "/var/lib/silverbullet";
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

    topology.self.services.silverbullet = {
      name = "Silverbullet";
      details.listen.text = "sb.${hostname}";
    };
  };
}
