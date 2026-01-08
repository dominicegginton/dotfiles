{ config, lib, hostname, pkgs, ... }:

{
  config = lib.mkIf config.services.silverbullet.enable {
    services.silverbullet = {
      listenAddress = "0.0.0.0";
      listenPort = 8765;
      openFirewall = false;
    };

    services.nginx.enable = true;
    services.nginx.virtualHosts."sb.${hostname}" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://${config.services.silverbullet.listenAddress}:${toString config.services.silverbullet.listenPort}";
    };

    users.users.silverbullet.extraGroups = [ "fuse" ];

    systemd.services.silverbullet-gcs-mount = {
      description = "Mount GCS bucket for Silverbullet data";
      after = [ "network-online.target" "decrypt-secrets.service" ];
      requires = [ "decrypt-secrets.service" "network-online.target" ];
      before = [ "silverbullet.service" ];
      wantedBy = [ "silverbullet.service" ];
      path = [ pkgs.util-linux pkgs.gcsfuse pkgs.coreutils pkgs.fuse ];
      preStart = lib.mkIf (!lib.hasPrefix "/var/lib/" config.services.silverbullet.spaceDir) ''mkdir -p ${config.services.silverbullet.spaceDir}''; 
      serviceConfig = {
        Type = "simple";
        User = config.services.silverbullet.user;
        Groups = config.services.silverbullet.group;
        ExecStart = "${pkgs.gcsfuse}/bin/gcsfuse --foreground silverbullet-data-c3c7e5776e8ad852 ${config.services.silverbullet.spaceDir}";
        Restart = "on-failure";
      };
    };

    topology.self.services.silverbullet = {
      name = "Silverbullet";
      details.listen.text = "sb.${hostname}";
    };
  };
}
