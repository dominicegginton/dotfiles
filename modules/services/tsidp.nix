{
  config,
  tailnet,
  lib,
  ...
}:

let
  cfg = config.services.tsidp;
in

{
  config = lib.mkIf cfg.enable {
    services.tsidp.settings = {
      # Enable OAuth token exchange using RFC 8693
      enableSts = lib.mkDefault true;
      enableFunnel = lib.mkDefault true;
    };

    # Persistent storage for Tailscale IDP database and state
    environment.persistence."/persist".directories = lib.mkIf config.impermanence.enable [
      "/var/lib/tsidp"
    ];

    topology.self = {
      interfaces.tsidp = {
        network = tailnet;
        addresses = [ "https://idp.${tailnet}" ];
      };

      services.idp = {
        name = "Tailscale IDP";
        details.listen.text = "https://idp.${tailnet}";
      };
    };
  };
}
