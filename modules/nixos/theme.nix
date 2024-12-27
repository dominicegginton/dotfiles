{ config, lib, pkgs, theme, ... }:

{
  config = {
    environment.etc.theme.text = theme;

    #   systemd.timers.theme = {
    #     wantedBy = [ "timers.target" ];
    #     timerConfig = {
    #       OnCalendar = "*:0/1";
    #       Persistent = true;
    #       Unit = "auto-theme.service";
    #     };
    #   };
    #
    #   systemd.services.theme = {
    #     serviceConfig.Type = "oneshot";
    #     script = lib.concatStringsSep "\n" [
    #       ''
    #         current_time=$(${pkgs.coreutils}/bin/date +%H:%M)
    #         ${pkgs.gum}/bin/gum log --prefix log --level info "Current time: $current_time"
    #         if [ "$current_time" \> "06:00" ] && [ "$current_time" \< "18:00" ]; then
    #             ${pkgs.coreutils}/bin/echo "light" > /etc/theme
    #         else
    #             ${pkgs.coreutils}/bin/echo "dark" > /etc/theme
    #         fi
    #         ${pkgs.gum}/bin/gum log --prefix theme --level info "Theme set to: $(${pkgs.coreutils}/bin/cat /etc/theme)"
    #       ''
    #       (
    #         if config.modules.display.plasma.enable then
    #           ''
    #             ${pkgs.gum}/bin/gum log --prefix theme --level info "Setting Plasma theme"
    #             if [ "$(${pkgs.coreutils}/bin/cat /etc/theme)" = "light" ]; then
    #                 ${pkgs.libsForQt5.plasma-workspace}/bin/plasma-apply-desktoptheme breeze-light
    #                 ${pkgs.libsForQt5.plasma-workspace}/bin/plasma-apply-lookandfeel -a org.kde.breezelight.desktop
    #             else
    #                 ${pkgs.libsForQt5.plasma-workspace}/bin/plasma-apply-desktoptheme breeze-dark
    #                 ${pkgs.libsForQt5.plasma-workspace}/bin/plasma-apply-lookandfeel -a org.kde.breezedark.desktop
    #             fi
    #             ${pkgs.gum}/bin/gum log --prefix theme --level info "Plasma theme set"
    #           ''
    #         else
    #           ''''
    #       )
    #     ];
    #   };
    #
    #   system.activationScripts.theme = {
    #     supportsDryActivation = true;
    #     text = config.systemd.services.theme.script;
    #   };
  };
}
