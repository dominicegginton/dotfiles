{
  config,
  lib,
  ...
}:

{
  config = lib.mkIf config.services.jellyfin.enable {
    # Ensure Tailscale is available for secure access
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "services.tailscale.enable must be set to true";
      }
    ];

    # Keep the local firewall closed as we use Tailscale Serve
    services.jellyfin.openFirewall = lib.mkDefault false;

    # Expose Jellyfin via Tailscale Serve on the standard HTTP port
    services.tailscale.serve = {
      enable = true;
      services."jellyfin".endpoints."tcp:80" = "http://127.0.0.1:${toString 8096}";
    };
  };
}
