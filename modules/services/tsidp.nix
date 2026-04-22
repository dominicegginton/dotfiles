{
  config,
  tailnet,
  lib,
  ...
}:

{
  config = lib.mkIf config.services.tsidp.enable {
    services.tsidp.settings.enableSts = lib.mkDefault true;

    topology.self.services.tsidp = {
      name = "tsidp";
      details.listen.text = "https://idp.${tailnet}";
    };
  };
}
