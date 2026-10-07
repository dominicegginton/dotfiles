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

  config = lib.mkIf (cfg.enable && cfg.credentialsFile != null) {
    users.users.vector = {
      isSystemUser = true;
      group = "vector";
      extraGroups = [ "systemd-journal" ];
    };
    users.groups.vector = { };

    systemd.services.vector = {
      wants = [
        "sops-nix.service"
        "network-online.target"
      ];
      after = [
        "sops-nix.service"
        "network-online.target"
      ];
      serviceConfig = lib.mkHardenedSystemdServiceConfig {
        User = "vector";
        Group = "vector";
        DynamicUser = lib.mkForce false;
        # Vector (Tokio) needs epoll/eventfd; default hardening denies @resources syscalls.
        memoryDenyWriteExecute = false;
        systemCallFilter = [
          "@system-service"
          "~@privileged"
        ];
        restrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
          "AF_NETLINK"
        ];
        # ProtectProc = "invisible" and ProcSubset = "pid" hide /proc/sys/kernel/random/boot_id
        # which journalctl needs to retrieve the boot ID.
        ProtectProc = lib.mkForce "default";
        ProcSubset = lib.mkForce "all";
        ReadWritePaths = [ "/var/lib/vector" ];
        BindReadOnlyPaths = [
          "-/var/log/journal"
          "-/run/log/journal"
          "-/run/systemd/journal"
          "-/etc/ssl/certs"
          "-/run/secrets"
          "-/run/secrets.d"
          "-/proc/sys/kernel/random/boot_id"
        ]
        ++ lib.optional (cfg.credentialsFile != null) "-${cfg.credentialsFile}";
        # nixpkgs sets AmbientCapabilities; empty bounding set would drop them.
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      };
      environment = {
        SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
      };
    };

    environment.persistence."/persist".directories = lib.mkIf config.impermanence.enable [
      {
        directory = "/var/lib/vector";
        user = "vector";
        group = "vector";
        mode = "0700";
      }
    ];

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

              # Map journald PRIORITY (syslog 0-7) to GCP severity strings
              p = to_int(.PRIORITY) ?? 6

              # Linux kernel audit logs (_TRANSPORT = "audit") default to PRIORITY 0 in journald,
              # which would incorrectly map to EMERGENCY. Map audit logs to INFO (6).
              if ._TRANSPORT == "audit" || .SYSLOG_IDENTIFIER == "audit" || exists(._AUDIT_TYPE) {
                p = 6
              }

              if p == 0 {
                .severity = "EMERGENCY"
              } else if p == 1 {
                .severity = "ALERT"
              } else if p == 2 {
                .severity = "CRITICAL"
              } else if p == 3 {
                .severity = "ERROR"
              } else if p == 4 {
                .severity = "WARNING"
              } else if p == 5 {
                .severity = "NOTICE"
              } else if p == 6 {
                .severity = "INFO"
              } else if p == 7 {
                .severity = "DEBUG"
              } else {
                .severity = "DEFAULT"
              }
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
            severity_key = "severity";
            resource = {
              type = "global";
            };
          };
        };
      };
    };
  };
}
