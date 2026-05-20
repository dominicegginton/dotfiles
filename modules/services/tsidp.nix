{
  config,
  tailnet,
  lib,
  ...
}:

{
  config = lib.mkIf config.services.tsidp.enable {
    # Enable OAuth token exchange using RFC 8693.
    services.tsidp.settings.enableSts = lib.mkDefault true;

    # Tailscale IDP topology definition.
    topology.self.services.tsidp = {
      name = "tsidp";
      details.listen.text = "https://idp.${tailnet}";
    };
  };
}
