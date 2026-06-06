{ lib, ... }:

{
  # SSH server hardening
  services.openssh = {
    enable = lib.mkForce true;
    allowSFTP = lib.mkForce false; # Disable SFTP for improved security
    authorizedKeysInHomedir = lib.mkForce false; # Keep keys in a central location
    settings = {
      KbdInteractiveAuthentication = lib.mkDefault false; # Disable interactive passwords by default
      LogLevel = lib.mkForce "VERBOSE";
      PermitRootLogin = lib.mkForce "no";
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

    # Allow TCP forwarding
    # Disable X11 and agent forwarding for security
    # Agent forwarding is disabled to prevent credential theft
    # Close stale connections after 10 minutes to reduce attack surface
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
