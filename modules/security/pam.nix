{ lib, config, ... }:

let
  # Custom PAM profile with brute-force protection using pam_faillock
  pamfile = ''
    # Fail lock after 3 attempts, lock for 15 minutes (unlock_time=0 means manual unlock)
    auth required pam_faillock.so preauth silent audit deny=3 fail_interval=900 unlock_time=0
    ${lib.optionalString config.users.sssd.enable "auth sufficient pam_sss.so"}
    auth sufficient pam_unix.so nullok try_first_pass
    auth [default=die] pam_faillock.so authfail audit deny=3 fail_interval=900 unlock_time=0
    auth sufficient pam_faillock.so authsucc

    account required pam_faillock.so
    ${lib.optionalString config.users.sssd.enable "account [default=bad success=ok user_unknown=ignore] pam_sss.so"}
  '';
in

{
  security.pam = {
    # Apply custom fail-lock protection to login and SSH services
    services = {
      login.text = lib.mkIf (!config.wsl.enable) (lib.mkDefault pamfile);
      sshd.text = lib.mkIf (!config.wsl.enable) (lib.mkDefault pamfile);
      gdm-password.text = lib.mkIf (config.display.gnome.enable && !config.wsl.enable) (
        lib.mkDefault pamfile
      );
      systemd-run0 = {
        setLoginUid = lib.mkDefault true;
        pamMount = lib.mkDefault true;
      };
    };

    # Limit maximum concurrent logins per user
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
