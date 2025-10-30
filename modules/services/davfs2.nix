{ config, lib, ... }:

{
  config.users.users.dom.extraGroups = lib.mkIf config.services.davfs2.enable [ "dav2fs" ];
}


