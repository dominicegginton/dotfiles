{ lib, ... }:

{
  # SSH server hardening
  services.openssh = {
    enable = lib.mkForce true;
    allowSFTP = lib.mkForce false; # Disable SFTP for improved security
    authorizedKeysInHomedir = lib.mkForce false; # Keep keys in a central location
    settings = {
      KbdInteractiveAuthentication = lib.mkForce false; # Disable interactive passwords
      LogLevel = lib.mkForce "VERBOSE";
      PermitRootLogin = lib.mkForce "no"; # Never allow root login via SSH
      UsePAM = lib.mkForce true;
      # Restrict to secure HMACs and Ciphers
      Macs = [
        "hmac-sha2-512"
        "hmac-sha2-256"
      ];
      Ciphers = [
        "aes256-ctr"
        "aes192-ctr"
        "aes128-ctr"
      ];
    };
    extraConfig = ''
      AllowTcpForwarding yes
      X11Forwarding no
      AllowAgentForwarding no
      AllowStreamLocalForwarding no
      ClientAliveInterval 600
      ClientAliveCountMax 1
    '';
  };
}
