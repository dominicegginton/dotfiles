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
      description = "Run systemd-analyze security report to journald";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      path = with pkgs; [
        systemd
      ];

      script = ''
        echo "Generating systemd security analysis report..."
        systemd-analyze security --no-pager
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
