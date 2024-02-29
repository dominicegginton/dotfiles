# Environment.
#
# NixOS environment configuration.
{pkgs, ...}: {
  environment = {
    # System packages for host are avaible
    # to all users.
    systemPackages = with pkgs; [
      gitMinimal
      vim
      home-manager
      unzip
      usbutils
      wget
      htop-vim
      btop
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

    # Set vim as default editor.
    variables.EDITOR = "vim";
    variables.SYSTEMD_EDITOR = "vim";
    variables.VISUAL = "vim";
  };
}
