{ pkgs
, config
, lib
, ...
}:

let
  hasGraphical =
    config.display.gnome.enable || config.display.niri.enable || config.display.driftwm.enable;
in
{
  # Core system packages
  environment.systemPackages =
    with pkgs;
    [
      clamav
      curl
      git
      git-lfs
      gitleaks
      gnupg
      nix-gc-dangling-links
      nix-output-monitor
      opencryptoki
      openssh
      openssl
      pinentry-curses
      vulnix
      vlock
      wget
      sc
    ]
    ++ lib.optional (!config.wsl.enable) run0-sudo-shim
    ++ lib.optional hasGraphical vimb;

  environment.defaultPackages = lib.mkDefault [ ];
}
