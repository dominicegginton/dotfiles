{ lib, ... }:

let
  pamfile = ''
    auth required pam_faillock.so preauth silent audit deny=3 fail_interval=900 unlock_time=0
    auth sufficient pam_unix.so nullok try_first_pass
    auth [default=die] pam_faillock.so authfail audit deny=3 fail_interval=900 unlock_time=0
    auth sufficient pam_faillock.so authsucc

    account required pam_faillock.so
  '';
in

{
  environment.etc."pam_pkcs11/pam_pkcs11.conf".text = lib.mkDefault ''
    cert_policy = ca,signature,ocsp_on,crl_auto;
  '';

  security.pam = {
    services = {
      login.text = lib.mkDefault pamfile;
      sshd.text = lib.mkDefault pamfile;
      systemd-run0 = {
        setLoginUid = lib.mkDefault true;
        pamMount = lib.mkDefault true;
      };
    };

    p11.enable = lib.mkDefault true;

    loginLimits = lib.mkDefault [
      {
        domain = "*";
        item = "maxlogins";
        type = "hard";
        value = "10";
      }
    ];
  };
}
