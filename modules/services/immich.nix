{
  config,
  lib,
  tailnet,
  ...
}:

{
  config = lib.mkIf config.services.immich.enable {
    services.immich.host = "0.0.0.0";

    services.tailscale.serve = {
      enable = true;
      services."immich".endpoints."tcp:443" = "http://127.0.0.1:${toString 2283}";
    };

    topology.self.services.immich = {
      name = "Immich";
      details.listen.text = "https://immich.${tailnet}";
    };
  };
}
