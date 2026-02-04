{
  config,
  lib,
  tailnet,
  ...
}:

{
  config = lib.mkIf config.services.silverbullet.enable {
    services.silverbullet = {
      listenAddress = "0.0.0.0";
      listenPort = 8765;
      openFirewall = false;
    };

    services.tailscale.serve = {
      enable = true;
      services."sb".endpoints."tcp:443" =
        "https+insecure://127.0.0.1:${builtins.toString config.services.silverbullet.listenPort}";
    };

    topology.self.services.silverbullet = {
      name = "Silverbullet";
      details.listen.text = "https://sb.${tailnet}";
    };
  };
}
