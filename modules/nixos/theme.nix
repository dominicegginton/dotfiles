{ config, lib, pkgs, ... }:

{
  config = {
    systemd.timers.theme = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*:0/1";
        Persistent = true;
        Unit = "auto-theme.service";
      };
    };
    systemd.services.theme = {
      serviceConfig.Type = "oneshot";
      script = ''
        current_time=$(${pkgs.coreutils}/bin/date +%H:%M)
        ${pkgs.gum}/bin/gum log --level info "Current time: $current_time"
        if [ "$current_time" \> "06:00" ] && [ "$current_time" \< "18:00" ]; then
            ${pkgs.coreutils}/bin/echo "light" > /etc/theme
        else
            ${pkgs.coreutils}/bin/echo "dark" > /etc/theme
        fi
        ${pkgs.gum}/bin/gum log --level info "Theme set to: $(${pkgs.coreutils}/bin/cat /etc/theme)"
      '';
    };
    system.activationScripts.theme = {
      supportsDryActivation = true;
      text = config.systemd.services.theme.script;
    };
  };
}
