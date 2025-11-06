{ ... }:
{
  # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268155
  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=0
  '';
  # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268156
  security.sudo.wheelNeedsPassword = true;
}
