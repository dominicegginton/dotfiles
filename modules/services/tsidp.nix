{
  config,
  tailnet,
  ...
}:

{
  config = lib.mkIf config.services.tsidp.enable {
    services.tsidp.settings.enableSts = true;

    topology.self.services.tsidp = {
      name = "tsidp";
      details.listen.text = "https://idp.${tailnet}";
    };
  };
}
