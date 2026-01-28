{
  self,
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.services.lldap.enable {
    # TODO: replace this service with a better method of ensuring the password file exists on
    #       all systems before nslcd starts (maybe using secrets module?) - llap service is not
    #       guaranteed to be present on all systems using ldap users
    systemd.services.nslcd.serviceConfig.ReadWritePaths = [ "/var/lib/lldap" ];
    systemd.services.nslcd-password-setup = {
      description = "Setup nslcd LDAP bind password";
      wantedBy = [ "nslcd.service" ];
      before = [ "nslcd.service" ];
      after = [
        "lldap.service"
        "lldap-user-password.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        mkdir -p /run/nslcd
        cp /var/lib/lldap/user_password /run/nslcd/bind-password
        chown nslcd:nslcd /run/nslcd/bind-password
        chmod 400 /run/nslcd/bind-password
      '';
    };

    users.ldap = {
      enable = true;
      server = "ldap://${self.outputs.nixosConfigurations.latitude-7390.config.networking.hostName}:${toString config.services.lldap.settings.ldap_port}/";
      base = config.services.lldap.settings.ldap_base_dn;
      daemon.enable = true;
      bind = {
        distinguishedName = "uid=admin,ou=people,dc=dominicegginton,dc=dev";
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
      su = {
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
