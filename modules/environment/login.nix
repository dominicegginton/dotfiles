{ lib, ... }:

{
  environment.etc."login.defs".text = lib.mkForce ''
    ENCRYPT_METHOD SHA256
    PASS_MIN_DAYS 1
    PASS_MAX_DAYS 60
    FAIL_DELAY 4
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
  '';
}
