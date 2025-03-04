{ config, lib, pkgs, ... }:

with lib;
with pkgs.writers;

let
  backup = writeBashBin "backup" ''
    export PATH=${makeBinPath [ pkgs.coreutils ]}:$PATH
    set -eu
    echo "backup ..."
  '';
in

{
  options.modules.backup.schedule = mkOption {
    type = types.str;
    default = "1h";
    description = "Backup schedule";
  };
  config = {
    systemd.timers.backup = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "0m";
        OnUnitActiveSec = config.modules.backup.schedule;
        Unit = "backup.service";
      };
    };
    systemd.services.backup = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "secrets.target" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      script = ''
        export PATH=${makeBinPath [ pkgs.coreutils ]}:$PATH
        set -eu
        echo "backup ..."
      '';
    };
    system.activationScripts.backup = {
      text = config.systemd.services.backup.script;
      deps = [ "specialfs" ];
    };
    system.activationScripts.users.deps = [ "backup" ];
    environment.systemPackages = [ backup ];
  };
}
