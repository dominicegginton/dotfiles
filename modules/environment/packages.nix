{
  pkgs,
  config,
  lib,
  ...
}:

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
    ++ lib.optional (!config.wsl.enable) run0-sudo-shim;

  environment.defaultPackages = lib.mkDefault [ ];
}
