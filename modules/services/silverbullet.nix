{
  config,
  lib,
  tailnet,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.services.silverbullet.enable {
    services.silverbullet = {
      listenAddress = "0.0.0.0";
      listenPort = 8765;
      openFirewall = lib.mkDefault false;
      user = lib.mkDefault "silverbullet";
      spaceDir = lib.mkDefault "/var/lib/silverbullet";
    };

    services.tailscale.serve = {
      enable = true;
      services."silverbullet".endpoints."tcp:443" =
        "https+insecure://127.0.0.1:${builtins.toString config.services.silverbullet.listenPort}";
    };

    topology.self.services.silverbullet = {
      name = "Silverbullet";
      details.listen.text = "https://silverbullet.${tailnet}";
    };
  };
}
