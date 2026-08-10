{ config, lib, ... }:

{
  # Enable fail2ban for brute-force defense
  services.fail2ban = {
    enable = lib.mkDefault (!config.wsl.enable && config.networking.firewall.enable != false);
    maxretry = lib.mkDefault 5;
    bantime = lib.mkDefault "1h";
    bantime-increment = {
      enable = lib.mkDefault true;
      multipliers = lib.mkDefault "1 2 4 8 16 32 64";
      maxtime = lib.mkDefault "48h";
    };
    jails = {
      sshd.settings = {
        mode = lib.mkDefault "aggressive";
      };
    };
  };
}
