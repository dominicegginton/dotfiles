{ config, lib, ... }:
{
  # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268153
  services.cron = {
    enable = true;
    systemCronJobs = lib.mkDefault [
      "00 0 * * 0\troot\taide -c /etc/aide/aide.conf --check | /bin/mail -s \"aide integrity check run for ${config.networking.hostName}\" root@notareal.email"
    ];
  };
}
