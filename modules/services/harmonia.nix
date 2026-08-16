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
    };

    # Expose Harmonia over tsnsrv on your tailnet
    services.tsnsrv.services."cache" = {
      toURL = "http://127.0.0.1:5005";
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
