{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.security.systemd-analyze = {
    enable = lib.mkEnableOption "systemd-analyze security reporting" // {
      default = true;
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      description = "Systemd calendar expression for when to run the security analysis.";
    };
  };

  config = lib.mkIf (config.security.systemd-analyze.enable && !config.wsl.enable) {
    systemd.services.systemd-security-analyze = {
      description = "Run systemd-analyze security and alert audit email";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      path = with pkgs; [
        systemd
      ];

      script = ''
        if ! command -v sendmail &>/dev/null; then
          echo "Warning: sendmail command not found. Cannot send email alert. Logging report instead:"
          systemd-analyze security --no-pager
          # TODO: Configure a system-wide mail server / SMTP client (like msmtp) or setup a GCP Cloud Monitoring alert
          # so that both this script and the auditd service can route and dispatch email alerts.
          exit 0
        fi

        echo "Generating systemd security report..."
        report=$(systemd-analyze security --no-pager)

        sendmail -t <<EOF
        To: ${config.security.audit-compliance.adminEmail}
        Subject: Systemd Security Analysis Report - $(hostname)
        MIME-Version: 1.0
        Content-Type: text/plain; charset=utf-8

        $report
        EOF
      '';

      serviceConfig = {
        Type = "oneshot";
        User = "root";

        # Systemd Service Hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RestrictNamespaces = true;
        LockPersonality = true;
        SystemCallArchitectures = "native";
      };
    };

    systemd.timers.systemd-security-analyze = {
      description = "Timer for systemd-security-analyze service";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = config.security.systemd-analyze.interval;
        Persistent = true;
      };
    };
  };
}
