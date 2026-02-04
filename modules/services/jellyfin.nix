{
  config,
  lib,
  hostname,
  ...
}:

{
  config = lib.mkIf config.services.jellyfin.enable {
    services.tailscale.serve = {
      enable = true;
      services."jellyfin".endpoints."tcp:80" = "http://127.0.0.1:${toString 8096}";
    };
  };
}
