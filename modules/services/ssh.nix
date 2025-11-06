{ lib, ... }:
{

  # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268159
  services.openssh.enable = true;

  # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268089
  services.openssh.settings.Ciphers = [
    "aes256-ctr"
    "aes192-ctr"
    "aes128-ctr"
  ];

  # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268157
  services.openssh.settings.Macs = [
    "hmac-sha2-512"
    "hmac-sha2-256"
  ];

  # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268176
  services.openssh.settings.UsePAM = true;

  # set the ssh banner to be the same as the getty greeting
  services.openssh.banner = lib.mkDefault config.services.getty.greetingLine;

  # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268088
  services.openssh.settings.LogLevel = "VERBOSE";

  # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268137
  services.openssh.settings.PermitRootLogin = "no";

  services.openssh.extraConfig = lib.strings.concatLines [
    # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268142
    ''
      ClientAliveInterval 600
    ''
    # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268143
    ''
      ClientAliveCountMax 1
    ''
  ];
}
