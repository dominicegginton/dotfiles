{ pkgs }:

pkgs.writeShellApplication {
  name = "gpg-import-keys";

  runtimeInputs = with pkgs; [
    pinentry
    gnupg
    google-cloud-sdk
  ];

  text = ''
    gcloud auth login
    if [ ! -d "$HOME"/.gnupg ]; then
      mkdir "$HOME"/.gnupg
    fi
    gsutil rsync -r gs://dominicegginton/gpg "$HOME"/.gnupg
    gpg --import "$HOME"/.gnupg/*
  '';
}
