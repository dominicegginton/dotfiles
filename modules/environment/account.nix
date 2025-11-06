{ lib, ... }:
{
  # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268174
  environment.etc."/default/useradd".text = lib.mkForce ''
    INACTIVE=35
  '';
}
