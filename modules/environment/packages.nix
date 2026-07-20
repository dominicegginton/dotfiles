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
      clamav # Antivirus engine for detecting trojans, viruses, malware
      curl # Command line tool for transferring data with URLs
      git # Distributed version control system
      gnupg # GNU Privacy Guard for encryption and signing
      nix-gc-dangling-links # Utility to clean up dangling symlinks in the Nix store
      nix-output-monitor # Monitor and colorize Nix build output
      opencryptoki # PKCS#11 implementation for hardware security tokens
      openssh # Secure shell for remote access
      openssl # Toolkit for TLS and general cryptography
      pinentry-curses # Curses-based PIN or passphrase entry dialog
      vulnix # Vulnerability scanner for Nix store paths
      vlock # Terminal locking utility for session security
      wget # Tool for retrieving files using HTTP, HTTPS, FTP and FTPS
      sc # Curses-based spreadsheet program
    ]
    ++ lib.optional (!config.wsl.enable) run0-sudo-shim;
}
