{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.environment;
in {
  config = {
    environment = {
      systemPackages = with pkgs; [
        gitMinimal # git
        vim # vim
        home-manager # home-manager
        unzip # unzip utility
        usbutils # usb utilities
        wget # http client
        htop-vim # system monitor
        btop # system monitor
        rebuild-host
        rebuild-home
        rebuild-configuration
        upgrade-configuration
        cleanup-trash
        shutdown-host
        reboot-host
        suspend-host
        hibernate-host
      ];

      variables.EDITOR = "vim";
      variables.SYSTEMD_EDITOR = "vim";
      variables.VISUAL = "vim";
    };
  };
}
