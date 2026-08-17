{
  config,
  lib,
  pkgs,
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

  config = lib.mkIf (cfg.enable && cfg.credentialsFile != null) {
    services.vector = {
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

    environment.persistence."/persist".directories = lib.mkIf (config.environment.persistence ? "/persist") [
      "/var/lib/vector"
    ];
  };
}
