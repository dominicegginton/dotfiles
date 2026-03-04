{
  config,
  lib,
  pkgs,
  hostname,
  tailnet,
  ...
}:

{
  config = lib.mkIf config.services.lldap.enable {
    users.ldap = {
      enable = true;
      server = "ldap://dit.${tailnet}";
      base = config.services.lldap.settings.ldap_base_dn;
      daemon.enable = true;
      bind = {
        distinguishedName = "uid=${hostname},ou=machines,dc=T2YHuJgy2121CNTRL";
        passwordFile = "/run/nslcd/bind-password";
      };
    };

    security.pam.services = {
      sudo.makeHomeDir = true;
      login.makeHomeDir = true;
      sshd.makeHomeDir = true;
      systemd-run0 = {
        makeHomeDir = true;
        text = lib.mkForce ''
          # Account management.
          account sufficient ${pkgs.nss_pam_ldapd}/lib/security/pam_ldap.so
          account required ${pkgs.pam}/lib/security/pam_unix.so

          # Authentication management.
          auth sufficient ${pkgs.pam}/lib/security/pam_rootok.so
          auth required ${pkgs.pam}/lib/security/pam_faillock.so
          auth sufficient ${pkgs.pam}/lib/security/pam_unix.so likeauth try_first_pass
          auth sufficient ${pkgs.nss_pam_ldapd}/lib/security/pam_ldap.so use_first_pass
          auth required ${pkgs.pam}/lib/security/pam_deny.so

          # Password management.
          password sufficient ${pkgs.pam}/lib/security/pam_unix.so nullok yescrypt
          password sufficient ${pkgs.nss_pam_ldapd}/lib/security/pam_ldap.so

          # Session management.
          session required ${pkgs.pam}/lib/security/pam_env.so conffile=/etc/pam/environment readenv=0
          session required ${pkgs.pam}/lib/security/pam_unix.so
          session required ${pkgs.pam}/lib/security/pam_mkhomedir.so silent skel=/var/empty umask=0077
          session optional ${pkgs.nss_pam_ldapd}/lib/security/pam_ldap.so
          session optional ${pkgs.pam}/lib/security/pam_limits.so conf=/etc/security/limits.conf
        '';
      };
    };
  };
}
