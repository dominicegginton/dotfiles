{ config, lib, pkgs, ... }:

with lib;
with pkgs.writers;

{
  options.services.backup = with types;

    let
      backupConfigType = submodule {
        options = {
          project = mkOption {
            type = str;
            default = "dominicegginton-personal";
            description = "Google Cloud project to use for backups.";
            example = "dominicegginton-personal";
          };
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
          mirror = mkOption {
            type = bool;
            default = false;
            description = "Always mirror the source directory to the destination.";
            example = true;
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
          bucket = "gs://my-backup-bucket";
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
          description = "Backup timer for ${name}";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnBootSec = "5min";
            OnUnitActiveSec = schedule;
            Unit = "${name}.service";
          };
        }
      )
      config.services.backup;
    systemd.services = mapAttrs
      (
        name: { project, bucket, from, to, mirror, ... }: {
          description = "Backup service for ${name}";
          serviceConfig.type = "oneshot";
          serviceConfig.remainAfterExit = true;
          script = ''
            export PATH=${makeBinPath [ pkgs.gum pkgs.google-cloud-sdk pkgs.rsync ]}:$PATH;
            set -e
            if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
              gum log --level error "You are not authenticated with Google Cloud. Please run 'gcloud auth login' to authenticate."
              exit 1;
            fi 
            gcloud config set project "${project}" || {
              gum log --level error "Failed to set Google Cloud project. Please run 'gcloud config set project <your-project>' manually."
              exit 1;
            }
            gum log --level info "Starting backup from ${from} to ${bucket}/${to}..."
            gsutil -m rsync ${lib.optionalString mirror "-d"} -r "${from}" "${bucket}/${to}" || { 
              gum log --level error "Backkup failed."
              exit 1;
            }
            gum log --level info "Backup completed successfully."
          '';
        }
      )
      config.services.backup;
  };
}
