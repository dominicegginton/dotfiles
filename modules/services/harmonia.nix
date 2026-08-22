{
  config,
  lib,
  pkgs,
  tailnet,
  ...
}:

let
  cfg = config.services.harmonia-custom;
in

{
  options.services.harmonia-custom = {
    enable = lib.mkEnableOption "Harmonia binary cache server";
  };

  config = lib.mkIf cfg.enable {
    services.harmonia = {
      cache.enable = true;
      cache.settings.bind = "127.0.0.1:5005";
      cache.signKeyPaths = [ config.sops.secrets."services/harmonia/sign-key".path ];
    };

    # Override the default systemd socket activation port to 5005 to prevent conflict with Frigate (port 5000)
    systemd.sockets.harmonia = {
      socketConfig.ListenStream = lib.mkForce "127.0.0.1:5005";
    };

    # Expose Harmonia over tsnsrv on your tailnet
    services.tsnsrv.services."cache" = {
      toURL = "http://127.0.0.1:5005";
      tags = [ "tag:service-cache" ];
    };

    # Topology metadata for the private cache service
    topology.self = {
      interfaces.tsnsrv-cache = {
        network = tailnet;
        addresses = [ "https://cache.${tailnet}" ];
      };

      services.harmonia = {
        name = lib.mkForce "Harmonia Binary Cache";
        details.listen.text = lib.mkForce "127.0.0.1:5005";
      };
    };
  };
}
