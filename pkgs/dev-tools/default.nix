# Curated development and infrastructure tooling exposed as a package set (pkgs.devTools.*).
{ pkgs }:

with pkgs;

pkgs.lib.recurseIntoAttrs {
  inherit
    age
    burn-infector
    deploy-host
    google-cloud-sdk
    gpg-import-bucket
    mkpasswd
    nix
    nixos-anywhere
    opentofu
    secretspec
    sops
    ssh-to-age
    ;
}
