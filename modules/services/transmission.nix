{ config
, lib
, tailnet
, ...
}:

let
  cfg = config.services.transmission;
in

{
  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.mkSingletonAssertion "transmission" [
        "services"
        "transmission"
        "enable"
      ])
    ];

    # Transmission and tsnsrv use systemd PrivateUsers / DynamicUser and require user namespaces
    security.unprivilegedUserNamespaces.enable = true;

    services.transmission.settings = {
      download-dir = lib.mkDefault "/var/lib/transmission/Downloads";
      incomplete-dir = lib.mkDefault "/var/lib/transmission/.incomplete";
      incomplete-dir-enabled = lib.mkDefault true;
      rpc-bind-address = lib.mkDefault "127.0.0.1";
      rpc-port = lib.mkDefault 9091;
      rpc-whitelist-enabled = lib.mkDefault false;
      rpc-host-whitelist-enabled = lib.mkDefault false;
    };

    # Ensure directories exist with the correct permissions
    systemd.tmpfiles.rules = [
      "d ${config.services.transmission.settings.download-dir} 0775 transmission transmission -"
      "d ${config.services.transmission.settings.incomplete-dir} 0775 transmission transmission -"
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
