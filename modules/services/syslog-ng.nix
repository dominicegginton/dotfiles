{ lib, config, ... }:

let
  cfg = config.services.syslog-ng;
in

{
  options = {
    services.syslog-ng = {
      remote_hosts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "List of remote syslog-ng hosts to send logs to.";
      };
      remote_tls = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to use TLS when sending logs to remote syslog-ng hosts.";
      };
      certfile = lib.mkOption {
        type = lib.types.str;
        default = "/var/syslog-ng/certs.d/certificate.crt";
        description = "Path to the TLS certificate file for syslog-ng.";
      };
      keyfile = lib.mkOption {
        type = lib.types.str;
        default = "/var/syslog-ng/certs.d/certificate.key";
        description = "Path to the TLS key file for syslog-ng.";
      };
      cafile = lib.mkOption {
        type = lib.types.str;
        default = "/var/syslog-ng/certs.d/cert-bundle.crt";
        description = "Path to the TLS CA bundle file for syslog-ng.";
      };
    };
  };

  config = {
    # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268107
    services.syslog-ng.enable = true;

    services.syslog-ng.extraConfig = lib.strings.concatLines [
      ''
        source s_local { system(); internal(); };
      ''
      # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268108
      (lib.strings.optionalString (!cfg.remote_tls) ''
        destination d_network {
          ${lib.strings.concatMapStrings (host: ''
            syslog(
              ${host}
            );
          '') cfg.remote_hosts}
        };

        log { 
          source(s_local);
          destination(d_network);
        };
      '')

      # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268109
      (lib.strings.optionalString (cfg.remote_tls) ''
        destination d_network {
          ${lib.strings.concatMapStrings (host: ''
            syslog(
              ${host}
              transport(tls)
              tls(
                cert-file("${cfg.certfile}")
                key-file("${cfg.keyfile}")
                ca-file("${cfg.cafile}")
                peer-verify(yes)
              )
            );
          '') cfg.remote_hosts}
        };

        log { source(s_local); destination(d_local); destination(d_network); };
      '')
      # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268115
      ''
        options {
          owner(root);
          dir_owner(root);
        };
      ''
      # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268116
      ''
        options {
          group(root);
          dir_group(root);
        };
      ''
      # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268117
      ''
        options {
          dir_perm(0750);
        };
      ''
      # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268118
      ''
        options {
          perm(0640);
        };
      ''
    ];
  };
}
