#!/bin/sh

if ! [ -x "$(command -v gpg)" ]; then
  echo 'Error: gpg is not install.' >&2
  exit
fi

mkdir ~/.gpg
nix-shell -p google-cloud-sdk --run "gcloud init"
nix-shell -p google-cloud-sdk --run "gsutil rsync -r gs://dominicegginton/gpg/ ~/.gpg/"
gpg --import ~/.gpg/*
shred -z ~/.gpg/*
rm -rf ~/.gpg
