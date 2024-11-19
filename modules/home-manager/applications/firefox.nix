{ pkgs, config, lib, ... }:

with lib;

{
  config = {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox-devedition;
    };
  };
}
