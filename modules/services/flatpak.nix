{
  lib,
  config,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.services.flatpak.enable {
    # Flatpak requires unprivileged user namespaces for sandbox creation
    boot.kernel.sysctl."user.max_user_namespaces" = lib.mkDefault 10000;

    # Systemd service to add Flathub repository at boot
    systemd.services.flatpak-repo = lib.mkDefault {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      '';
      serviceConfig = {
        Type = "oneshot";
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        PrivateMounts = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        ProtectProc = "invisible";
        ProcSubset = "pid";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
          "AF_NETLINK"
        ];
        ReadWritePaths = [ "/var/lib/flatpak" ];
        StateDirectory = "flatpak";
        KeyringMode = "private";
        UMask = "0077";
      };
    };

    # Systemd service and timer to update Flatpak apps daily
    systemd.services.flatpak-update = lib.mkDefault {
      description = "Update Flatpak applications";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak update -y
      '';
      serviceConfig = {
        Type = "oneshot";
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        PrivateMounts = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        ProtectProc = "invisible";
        ProcSubset = "pid";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
          "AF_NETLINK"
        ];
        ReadWritePaths = [ "/var/lib/flatpak" ];
        StateDirectory = "flatpak";
        KeyringMode = "private";
        UMask = "0077";
      };
    };

    systemd.timers.flatpak-update = lib.mkDefault {
      description = "Timer to update Flatpak applications daily";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };

    environment.systemPackages = with pkgs; [
      flatpak
      bazaar
    ];

    systemd.packages = with pkgs; [
      flatpak
      bazaar
    ];

    environment.persistence."/persist".directories = lib.mkIf config.impermanence.enable [
      "/var/lib/flatpak"
    ];
  };
}
