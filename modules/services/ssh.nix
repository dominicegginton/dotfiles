{ config, lib, ... }:

{
  openssh = {
    enable = true;
    allowSFTP = false;
    banner = lib.mkDefault config.services.getty.greetingLine;
    settings = {
      KbdInteractiveAuthentication = lib.mkForce false;
      LogLevel = lib.mkForce "VERBOSE";
      PermitRootLogin = lib.mkForce "no";
      UsePAM = lib.mkForce true;
      Macs = [ "hmac-sha2-512" "hmac-sha2-256" ];
      Ciphers = [ "aes256-ctr" "aes192-ctr" "aes128-ctr" ];
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
