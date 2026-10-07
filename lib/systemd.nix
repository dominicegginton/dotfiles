# Shared systemd unit hardening for long-running and oneshot services.
#
# Usage in a NixOS module:
#   systemd.services.my-service.serviceConfig = lib.mkMerge [
#     { Type = "oneshot"; User = "myuser"; }
#     (lib.mkHardenedSystemdServiceConfig { })
#   ];
#
# Tunables (all optional) merge with any extra systemd serviceConfig keys in the same attrset:
#   privateDevices, privateMounts, privateNetwork, memoryDenyWriteExecute,
#   restrictAddressFamilies, systemCallFilter, umask

{ lib }:

let
  knownOptionNames = [
    "privateDevices"
    "privateMounts"
    "privateNetwork"
    "memoryDenyWriteExecute"
    "restrictAddressFamilies"
    "systemCallFilter"
    "umask"
  ];

  defaultOptions = {
    privateDevices = true;
    privateMounts = true;
    privateNetwork = false;
    memoryDenyWriteExecute = true;
    restrictAddressFamilies = [
      "AF_INET"
      "AF_INET6"
      "AF_UNIX"
    ];
    systemCallFilter = [
      "@system-service"
      "~@privileged"
      "~@resources"
    ];
    umask = "0077";
  };

  mkHardenedSystemdServiceConfig =
    args:
    let
      options = lib.intersectAttrs defaultOptions args;
      cfg = defaultOptions // options;
      extra = lib.removeAttrs args knownOptionNames;
    in
    {
      NoNewPrivileges = true;
      PrivateTmp = true;
      PrivateDevices = cfg.privateDevices;
      PrivateMounts = cfg.privateMounts;
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
      MemoryDenyWriteExecute = cfg.memoryDenyWriteExecute;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      RestrictNamespaces = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = cfg.systemCallFilter;
      RestrictAddressFamilies = cfg.restrictAddressFamilies;
      CapabilityBoundingSet = "";
      KeyringMode = "private";
      UMask = cfg.umask;
    }
    // lib.optionalAttrs cfg.privateNetwork {
      PrivateNetwork = true;
    }
    // extra;
in
{
  inherit mkHardenedSystemdServiceConfig;
}
