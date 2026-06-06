{
  config,
  lib,
  tailnet,
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

    services.tsnsrv.services."jellyfin" = {
      toURL = "http://127.0.0.1:8096";
      funnel = lib.mkDefault true;
    };

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
