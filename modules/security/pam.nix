{ lib, ... }:

{

  # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268179
  environment.etc."pam_pkcs11/pam_pkcs11.conf".text = lib.mkDefault ''
    cert_policy = ca,signature,ocsp_on,crl_auto;
  '';

  security.pam = {
    services =
      let
        # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268081
        pamfile = ''
          auth required pam_faillock.so preauth silent audit deny=3 fail_interval=900 unlock_time=0
          auth sufficient pam_unix.so nullok try_first_pass
          auth [default=die] pam_faillock.so authfail audit deny=3 fail_interval=900 unlock_time=0
          auth sufficient pam_faillock.so authsucc

          account required pam_faillock.so
        '';
      in
      {
        login.text = lib.mkDefault pamfile;
        sshd.text = lib.mkDefault pamfile;

        # https://github.com/NixOS/nixpkgs/pull/419588
        systemd-run0 = {
          setLoginUid = true;
          pamMount = false;
        };
      };

    # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268177
    p11.enable = true;


    # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268085
    loginLimits = [
      {
        domain = "*";
        item = "maxlogins";
        type = "hard";
        value = "10";
      }
    ];
  };
}
