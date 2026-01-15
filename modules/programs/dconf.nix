{ lib, ... }:

{
  programs.dconf.profiles.user.databases = with lib.gvariant; [
    {
      settings."org/gnome/desktop/session".idle-delay = mkUint32 600;
      locks = [ "org/gnome/desktop/session/idle-delay" ];
    }
  ];
}
