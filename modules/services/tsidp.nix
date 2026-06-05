{
  config,
  tailnet,
  lib,
  ...
}:

{
  config = lib.mkIf config.services.tsidp.enable {
    services.tsidp.settings = {
      # Enable OAuth token exchange using RFC 8693
      enableSts = lib.mkDefault true;
      funnel = lib.mkDefault true;
    };

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
