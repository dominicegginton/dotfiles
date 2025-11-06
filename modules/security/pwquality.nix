{ pkgs, lib, ... }:
{

  # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268170
  security.pam.services.passwd.text = lib.mkDefault (
    lib.mkBefore "password requisite ${pkgs.libpwquality.lib}/lib/security/pam_pwquality.so"
  );
  security.pam.services.chpasswd.text = lib.mkDefault (
    lib.mkBefore "password requisite ${pkgs.libpwquality.lib}/lib/security/pam_pwquality.so"
  );
  security.pam.services.sudo.text = lib.mkDefault (
    lib.mkBefore "password requisite ${pkgs.libpwquality.lib}/lib/security/pam_pwquality.so"
  );

  environment.etc."/security/pwquality.conf".text = lib.strings.concatLines [
    # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268126
    ''
      ucredit=-1
    ''
    # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268127
    ''
      lcredit=-1
    ''
    # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268128
    ''
      dcredit=-1
    ''
    # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268129
    ''
      difok=8
    ''
    # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268134
    ''
      minlen=15
    ''
    # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268145
    ''
      ocredit=-1
    ''
    # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268169
    ''
      dictcheck=1
    ''
  ];
}
