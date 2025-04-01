{ pkgs, config, lib, ... }:

with lib;

{
  config = mkIf pkgs.stdenv.isLinux {
    programs.firefox = {
      enable = true;
      package = pkgs.unstable.firefox-devedition;
    };
  };
}
