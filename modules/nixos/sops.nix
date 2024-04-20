{
  config,
  lib,
  ...
}:
with lib; {
  options.modules.sops = {};

  config = {
    sops.defaultSopsFile = ../../secrets.yaml;
  };
}
