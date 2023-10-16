{ stdenv, pkgs, ... }:

pkgs.writeShellApplication {
  name = "gpg-import-keys";

  runtimeInputs = with pkgs; [
    gnupg
    google-cloud-sdk
  ];

  text = ''
    gcloud auth login
    mkdir "$HOME"/gpg
    gsutil rsync -r gs://dominicegginton/gpg "$HOME"/gpg
    gpg --import "$HOME"/gpg/*
    rm -rf "$HOME"/gpg
  '';
}
