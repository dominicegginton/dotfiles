{ config
, lib
, pkgs
, ...
}:

{
  options.services.restic.backups = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }: {
          config.package = lib.mkDefault (pkgs.writeShellScriptBin "restic" ''
            exec ${pkgs.systemd}/bin/systemd-inhibit \
              --what=sleep:shutdown --mode=block --who=restic \
              --why=${lib.escapeShellArg "Restic backup ${name}"} \
              ${lib.getExe pkgs.restic} "$@"
          '');
        }
      )
    );
  };

  config.systemd.services = lib.mkMerge (
    lib.mapAttrsToList
      (name: _: {
        # Reverse stop ordering keeps the inhibitor alive through ExecStopPost.
        "restic-backups-${name}" = {
          bindsTo = [ "restic-inhibit-${name}.service" ];
          after = [ "restic-inhibit-${name}.service" ];
        };

        "restic-inhibit-${name}" = {
          description = "Inhibit sleep and shutdown during Restic backup ${name}";
          requires = [ "systemd-logind.service" ];
          after = [ "systemd-logind.service" ];
          unitConfig.StopWhenUnneeded = true;
          serviceConfig = {
            Type = "notify";
            NotifyAccess = "all";
            ExecStart = lib.escapeShellArgs [
              "${pkgs.systemd}/bin/systemd-inhibit"
              "--what=sleep:shutdown"
              "--mode=block"
              "--who=restic"
              "--why=Restic backup ${name}"
              "${pkgs.systemd}/bin/systemd-notify"
              "--ready"
              "--exec"
              ";"
              "--"
              "${pkgs.coreutils}/bin/sleep"
              "infinity"
            ];
          };
        };
      })
      config.services.restic.backups
  );
}
