{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vlock # Terminal locking utility for enhanced security when stepping away from the computer, preventing unauthorized access to the terminal session.
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
    nix-gc-dangling-links
  ];
}
