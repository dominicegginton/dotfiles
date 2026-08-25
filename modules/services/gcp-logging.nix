{
  config,
  lib,
  ...
}:

let
  cfg = config.services.gcp-logging;
in

{
  options.services.gcp-logging = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = !config.wsl.enable;
      description = "Enable GCP Cloud Logging log shipping via Vector.";
    };

    projectId = lib.mkOption {
      type = lib.types.str;
      default = "dominicegginton-personal";
      description = "Google Cloud Platform project ID.";
    };

    credentialsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = config.sops.secrets."services/gcp-logging/key".path or null;
      description = "Path to the GCP Service Account JSON key file for Cloud Logging authorization.";
    };

    logId = lib.mkOption {
      type = lib.types.str;
      default = "journald";
      description = "Log ID stream name in GCP Cloud Logging.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.vector = {
      isSystemUser = true;
      group = "vector";
      extraGroups = [ "systemd-journal" ];
    };
    users.groups.vector = { };

    systemd.services.vector.serviceConfig = {
      User = "vector";
      Group = "vector";
      DynamicUser = lib.mkForce false;
    };

    systemd.services.vector.environment = {
      SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
    };

    environment.persistence."/persist".directories =
      lib.mkIf (config.environment.persistence ? "/persist")
        [
          {
            directory = "/var/lib/vector";
            user = "vector";
            group = "vector";
            mode = "0700";
          }
        ];

    services.vector = lib.mkIf (cfg.credentialsFile != null) {
      enable = true;
      journaldAccess = true;
      settings = {
        sources = {
          journald = {
            type = "journald";
          };
        };

        transforms = {
          add_host_metadata = {
            type = "remap";
            inputs = [ "journald" ];
            source = ''
              .hostname = "${config.networking.hostName}"
            '';
          };
        };

        sinks = {
          stackdriver = {
            type = "gcp_stackdriver_logs";
            inputs = [ "add_host_metadata" ];
            project_id = cfg.projectId;
            log_id = cfg.logId;
            credentials_path = cfg.credentialsFile;
            resource = {
              type = "global";
            };
          };
        };
      };
    };
  };
}
