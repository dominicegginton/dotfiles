{
  config,
  lib,
  tailnet,
  ...
}:

let
  cfg = config.services.jellyfin;
in

{
  config = lib.mkIf cfg.enable {
    # Ensure Tailscale is available for secure access
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "services.tailscale.enable must be set to true";
      }
    ];

    # Keep the local firewall closed as we use Tailscale Serve
    services.jellyfin.openFirewall = lib.mkDefault false;

    services.tsnsrv.services."jellyfin" = {
      toURL = "http://127.0.0.1:8096";
      funnel = lib.mkDefault false;
      tags = [ "tag:service-jellyfin" ];
    };

    # Add jellyfin to transmission group to allow reading downloads
    users.users.jellyfin.extraGroups = lib.optional config.services.transmission.enable "transmission";

    # Persistent storage for Jellyfin configuration and database
    environment.persistence."/persist".directories = lib.mkIf config.impermanence.enable [
      "/var/lib/jellyfin"
    ];

    topology.self = {
      interfaces.tsnsrv-jellyfin = {
        network = tailnet;
        addresses = [ "https://jellyfin.${tailnet}" ];
      };

      services.jellyfin = {
        name = "Jellyfin";
        details.listen.text = "127.0.0.1:8096";
      };
    };
  };
}
