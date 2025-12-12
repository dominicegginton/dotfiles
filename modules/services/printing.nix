{ config, lib, ... }:

{
  config.users.users.dom.extraGroups = lib.mkIf (config.services.printing.enable && config.users.users.dom.enable) [ "lpadmin" ];
}

