{
  lib,
  config,
  tailnet,
  ...
}:

{
  config = lib.mkIf config.services.bitmagnet.enable {
    services.tailscale.serve = {
      enable = true;
      services."bitmagnet".endpoints."tcp:80" =
        "http://127.0.0.1:${toString config.services.bitmagnet.settings.http_server.port}";
    };

    topology.self.services.bitmagnet = {
      name = "BitMagnet";
      details.listen.text = "https://bitmagnet.${tailnet}";
    };
  };
}
