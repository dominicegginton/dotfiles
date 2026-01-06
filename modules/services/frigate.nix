{ config, lib, hostname, pkgs, ... }:

{
  config = lib.mkIf config.services.frigate.enable {
    services.frigate = {
      hostname = "fg.${hostname}";
      settings = {
        auth.enabled = false;
        motion.enabled = true;
        record.enabled = true;
        snapshots.enabled = true;
        detect = {
          enabled = true;
          fps = 5;
        };
      };
    };

    systemd.services."frigate-gcs-mount" = {
      description = "Mount GCS bucket for Frigate data";
      after = [ "network-online.target" "decrypt-secrets.service" ];
      requires = [ "decrypt-secrets.service" ];
      before = [ "frigate.service" ];
      wantedBy = [ "frigate.service" ];
      serviceConfig = {
        type = "forking";
        Restart= "always";
        Environment = {
          BUCKET = "frigate-data-c3c7e5776e8ad852";
          MOUNT_POINT = "/var/lib/frigate";
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

    topology.self.services.frigate = {
      name = "Frigate NVR";
      details.listen.text = config.services.frigate.hostname;
    };
  };
}
