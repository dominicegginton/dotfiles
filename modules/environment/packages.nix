{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vlock
    opencryptoki
    run0-sudo-shim
    openssl
    openssh
    curl
    wget
    git
    pinentry-curses
    gnupg
    clamav
  ];
}
