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

  # Set GPG_TTY dynamically for all interactive shell sessions
  environment.interactiveShellInit = ''
    export GPG_TTY=$(tty 2>/dev/null || echo "")
  '';

  # Persistent storage for user GnuPG keyring and trustdb
  environment.persistence."/persist".users.dom.directories = lib.mkIf config.impermanence.enable [
    ".gnupg"
  ];
}
