{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs = {
    gnupg.agent = {
      enable = lib.mkForce true; # Always enable GnuPG agent
      enableSSHSupport = lib.mkDefault true; # Enable SSH support through GnuPG agent
      pinentryPackage = lib.mkDefault (
        if (config.display.gnome.enable || config.display.niri.enable || config.display.driftwm.enable) then
          pkgs.pinentry-gnome3
        else
          pkgs.pinentry-curses
      );
    };
    # Disable regular SSH agent to avoid conflicts with GnuPG SSH support
    ssh.startAgent = lib.mkForce false;
  };
}
