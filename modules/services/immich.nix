{ config, lib, hostname, pkgs, ... }:

{
  config = lib.mkIf config.services.immich.enable {
    services.immich.host = "0.0.0.0";

    services.nginx = {
      enable = true;
      virtualHosts."immich.${hostname}" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://localhost:${toString 2283}";
      };
    };

    users.users.immich.extraGroups = [ "fuse" ];

    systemd.automounts = [{
      description = "Mount GCS bucket for Immich data";
      what = "immich-data-c3c7e5776e8ad852";
      where = "/var/lib/immich";
      type = "fuse.gcsfuse";
      options = "rw,allow_other,uid=${toString config.users.users.immich.uid},gid=${toString config.users.groups.immich.gid}";
      after = [ "network-online.target" "decrypt-secrets.service" ];
      requires = [ "network-online.target" "decrypt-secrets.service" ];
      before = [ "immich.service" ];
    }];
  };
}

