{ lib, config, ... }:

{
  config.services.nginx = lib.mkIf config.services.nginx.enable {
    # Use recommended security and performance presets
    recommendedGzipSettings = lib.mkDefault true;
    recommendedOptimisation = lib.mkDefault true;
    recommendedTlsSettings = lib.mkDefault true;
    recommendedProxySettings = lib.mkDefault true;
  };
}
