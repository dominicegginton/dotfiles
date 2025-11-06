{ lib, ... }:

{
  # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268086
  programs.dconf.profiles.user.databases = with lib.gvariant; [
    {
      settings."org/gnome/desktop/session".idle-delay = mkUint32 600;
      locks = [ "org/gnome/desktop/session/idle-delay" ];
    }
  ];
}
