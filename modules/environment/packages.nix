{ pkgs, ... }:

{
  # Core system packages
  environment.systemPackages = with pkgs; [
    vlock # Terminal locking utility for session security
    opencryptoki # PKCS#11 implementation for hardware security tokens
    run0-sudo-shim # Compatibility shim for systemd run0
    openssl # Toolkit for TLS and general cryptography
    openssh # Secure shell for remote access
    curl # Command line tool for transferring data with URLs
    wget # Tool for retrieving files using HTTP, HTTPS, FTP and FTPS
    git # Distributed version control system
    pinentry-curses # Curses-based PIN or passphrase entry dialog
    gnupg # GNU Privacy Guard for encryption and signing
    clamav # Antivirus engine for detecting trojans, viruses, malware
    nix-gc-dangling-links # Utility to clean up dangling symlinks in the Nix store
  ];
}
