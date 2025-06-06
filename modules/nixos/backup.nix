{ config, lib, pkgs, hostname, ... }:

with lib;
with pkgs.writers;

{
  options.backup = with types;

    let
      backupConfigType = submodule {
        options = {
          bucket = mkOption {
            type = str;
            default = "";
            description = "GCS bucket to store backups.";
            example = "gcs://bucket";
          };
          from = mkOption {
            type = str;
            default = "";
            description = "Source directory to back up.";
            example = "/var/lib/myapp";
          };
          to = mkOption {
            type = str;
            default = "";
            description = "Destination directory in the bucket.";
            example = "myapp-backups";
          };
          schedule = mkOption {
            type = str;
            default = "1d";
            description = "Systemd timer configuration for the backup job.";
            example = "1d";
          };
        };
      };
    in
    mkOption {
      type = attrsOf backupConfigType;
      default = { };
      description = "Configuration for backup jobs.";
      example = {
        exampleJob = {
          bucket = "gcs://my-backup-bucket";
          from = "/var/lib/myapp";
          to = "myapp-backups";
          schedule = "2m";
        };
      };
    };
  config = {
    systemd.timers = mapAttrs
      (
        name: { schedule, ... }: {
          description = "Backup timer for gcp-backup-${name}";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnBootSec = "0m";
            OnUnitActiveSec = schedule;
            Unit = "gcp-backup-${name}.service";
          };
        }
      )
      config.backup;
    systemd.services = mapAttrs
      (
        name: { bucket, from, to, ... }: {
          description = "Backup service for ${name}";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" "secrets.target" ];
          serviceConfig.type = "oneshot";
          serviceConfig.remainAfterExit = true;
          script = ''
            export PATH=${makeBinPath [ pkgs.gum pkgs.gcsfuse ]}:$PATH
            gum log --level error "NOT IMPLEMENTED: Backup from ${from} to ${bucket}/${hostname}/${to}"
          '';
        }
      )
      config.backup;
  };
}
