{ lib, config, ... }:

{
  config.services.nginx = lib.mkIf config.services.nginx.enable {
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
  };
}
