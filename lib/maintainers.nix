# lib/maintainers.nix
#
# Custom maintainer metadata and definitions merged with Nixpkgs standard maintainers.
# This keeps developer identity configurations organized and reusable.

{ lib }:

lib.recursiveUpdate lib.maintainers {
  # Dominic Egginton
  dominicegginton = {
    name = "Dominic Egginton";
    email = "dominic.egginton@gmail.com";
    github = "dominicegginton";
    githubId = 28626241;
    sshKeys = [ "ssh-rsa4096/4C79CE4F82847A9F" ];
  };
}
