{
  config,
  lib,
  ...
}:

{
  config = lib.mkIf config.services.jellyfin.enable {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "services.tailscale.enable must be set to true";
      }
    ];

    services.jellyfin.openFirewall = lib.mkDefault false;

    services.tailscale.serve = {
      enable = true;
      services."jellyfin".endpoints."tcp:80" = "http://127.0.0.1:${toString 8096}";
    };
  };
}
