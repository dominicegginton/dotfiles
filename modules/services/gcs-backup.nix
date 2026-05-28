{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.gcs-backup;
in
{
  options.services.gcs-backup = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
        {
          options = {
            enable = lib.mkEnableOption "Google Cloud Storage backup job";

            bucket = lib.mkOption {
              type = lib.types.str;
              description = "The name of the GCS bucket to backup to (e.g., 'gs://my-backup-bucket').";
              example = "gs://my-backups";
            };

            directories = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "List of directories to backup to the GCS bucket.";
              example = [
                "/var/lib/my-app"
                "/home/dom/documents"
              ];
            };

            serviceAccountKeyFile = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              description = "Path to the Google Cloud Service Account JSON key file for authentication.";
            };

            interval = lib.mkOption {
              type = lib.types.str;
              default = "daily";
              description = "How often to run the backup (systemd.timer calendar expression).";
              example = "hourly";
            };

            delete = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether to delete files in the bucket that are not present in the source.";
            };

            extraArgs = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Extra arguments to pass to gsutil rsync.";
              example = [
                "-x"
                ".*\\.tmp"
              ];
            };

            wantedBy = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "List of systemd units that should want this backup service.";
            };

            wants = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "List of systemd units that this backup service should want.";
            };
          };
        }
      )
    );
    default = { };
    description = "Google Cloud Storage backup jobs.";
  };

  config =
    let
      enabledJobs = lib.filterAttrs (_: job: job.enable) cfg;
    in
    lib.mkIf (enabledJobs != { }) {
      systemd.services = lib.mapAttrs' (
        name: job:
        lib.nameValuePair "gcs-backup-${name}" {
          description = "Backup job '${name}' to Google Cloud Storage";
          after = [ "network-online.target" ] ++ job.wantedBy ++ job.wants;
          wants = [ "network-online.target" ] ++ job.wants;
          wantedBy = job.wantedBy;
          path = [ pkgs.google-cloud-sdk ];
          environment = {
            CLOUDSDK_CONFIG = "/var/lib/gcs-backup/${name}";
          };
          script = ''
            ${lib.optionalString (job.serviceAccountKeyFile != null) ''
              gcloud auth activate-service-account --key-file=${job.serviceAccountKeyFile}
            ''}

            ${lib.concatMapStringsSep "\n" (dir: ''
              echo "Backing up ${dir} to ${job.bucket}..."
              gsutil -m rsync -r ${lib.optionalString job.delete "-d"} ${lib.escapeShellArgs job.extraArgs} "${dir}" "${job.bucket}/${config.networking.hostName}/${name}${dir}"
            '') job.directories}
          '';
          serviceConfig = {
            Type = "oneshot";
            User = "root";
            StateDirectory = "gcs-backup/${name}";
          };
        }
      ) enabledJobs;

      systemd.timers = lib.mapAttrs' (
        name: job:
        lib.nameValuePair "gcs-backup-${name}" {
          description = "Timer for Google Cloud Storage backup job '${name}'";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = job.interval;
            Persistent = true;
          };
        }
      ) enabledJobs;
    };
}
