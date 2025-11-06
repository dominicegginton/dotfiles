{ lib, ... }:
{
  environment.etc."login.defs".text = lib.mkForce (
    lib.strings.concatLines [
      # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268130
      ''
        ENCRYPT_METHOD SHA256
      ''
      # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268132
      ''
        PASS_MIN_DAYS 1
      ''
      # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268133
      ''
        PASS_MAX_DAYS 60
      ''
      # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268171
      ''
        FAIL_DELAY 4
      ''
      # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268181
      ''
        DEFAULT_HOME yes

        SYS_UID_MIN  400
        SYS_UID_MAX  999
        UID_MIN      1000
        UID_MAX      29999

        SYS_GID_MIN  400
        SYS_GID_MAX  999
        GID_MIN      1000
        GID_MAX      29999

        TTYGROUP     tty
        TTYPERM      0620

        # Ensure privacy for newly created home directories.
        UMASK        077

        # Uncomment this and install chfn SUID to allow nonroot
        # users to change their account GECOS information.
        # This should be made configurable.
        #CHFN_RESTRICT frwh
      ''

    ]
  );
}
