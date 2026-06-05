{
  config,
  tailnet,
  lib,
  ...
}:

{
  config = lib.mkIf config.services.tsidp.enable {
    # Enable OAuth token exchange using RFC 8693
    services.tsidp.settings.enableSts = lib.mkDefault true;

    topology.self = {
      interfaces.tsnsrv-idp = {
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
