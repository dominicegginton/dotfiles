{ config, lib, ... }:

{
  config.users.users.dom.extraGroups = lib.mkIf (config.services.davfs2.enable && config.users.users.dom.enable) [ "dav2fs" ];
}


