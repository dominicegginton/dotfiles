{
  config,
  lib,
  tailnet,
  ...
}:

let
  cfg = config.services.transmission;
in

{
  config = lib.mkIf cfg.enable {
    services.transmission.settings = {
      download-dir = "/mnt/data/transmission/Downloads";
      incomplete-dir = "/mnt/data/transmission/.incomplete";
      incomplete-dir-enabled = true;
      rpc-bind-address = "127.0.0.1";
      rpc-port = 9091;
      rpc-whitelist-enabled = false;
      rpc-host-whitelist-enabled = false;
    };

    # Ensure directories exist with the correct permissions
    systemd.tmpfiles.rules = [
      "d /mnt/data/transmission 0775 transmission transmission -"
      "d /mnt/data/transmission/Downloads 0775 transmission transmission -"
      "d /mnt/data/transmission/.incomplete 0775 transmission transmission -"
    ];

    # Expose transmission via tsnsrv reverse proxy
    services.tsnsrv.services."transmission" = {
      toURL = "http://127.0.0.1:9091";
      tags = [ "tag:service-transmission" ];
    };

    # Persistent storage for Transmission state and configuration
    environment.persistence."/persist".directories = lib.mkIf config.impermanence.enable [
      "/var/lib/transmission"
    ];

    topology.self = {
      interfaces.tsnsrv-transmission = {
        network = tailnet;
        addresses = [ "https://transmission.${tailnet}" ];
      };

      services.transmission = {
        name = "Transmission";
        details.listen.text = "127.0.0.1:9091";
      };
    };
  };
}
