{ lib, pkgs, ... }:

with lib;

{
  config = {
    systemd.services.gcsfuse = {
      after = [ "network.target" "network-setup.service" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      script = ''
        export PATH=${makeBinPath [ pkgs.gcsfuse ]}:$PATH
        echo "SKIPPING: gcsfuse is not yet supported"
        # export MOUNT_POINT=/mnt/gcs/
        # export BUCKET_NAME=
        # mkdir -p $MOUNT_POINT
        # gcsfuse $BUCKET_NAME $MOUNT_POINT
        # echo 1024 | sudo tee /sys/class/bdi/0:$(stat -c "%d" $MOUNT_POINT)/read_ahead_kb
      '';
    };
  };
}
