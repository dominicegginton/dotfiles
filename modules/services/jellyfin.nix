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

    # Persistent storage for Jellyfin media and metadata
    environment.persistence."/persist".directories = [
      "/var/lib/jellyfin"
    ];
  };
}
