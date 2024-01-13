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
      workspace.rebuild-host
      workspace.rebuild-home
      workspace.rebuild-configuration
      workspace.upgrade-configuration
      workspace.shutdown-host
      workspace.reboot-host
      workspace.hibernate-host
    ];

    # Set vim as default editor.
    variables.EDITOR = "vim";
    variables.SYSTEMD_EDITOR = "vim";
    variables.VISUAL = "vim";
  };
}
