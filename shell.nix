{ lib
, mkShell
, nix
, nixpkgs-fmt
, deadnix
, nix-diff
, nix-tree
, nix-health
, opentofu
, google-cloud-sdk
, gcsfuse
, pinentry
, gnupg
, writeShellScriptBin
, gum
, coreutils
}:

let
  tempdir = "/tmp/dominicegginton";
  gcpProject = "dominicegginton-personal";
in

mkShell {
  name = "dominicegginton/dotfiles";
  packages = [
    nix
    nixpkgs-fmt
    deadnix
    nix-diff
    nix-tree
    nix-health
    google-cloud-sdk
    gcsfuse
    opentofu
    coreutils
    gum
    google-cloud-sdk
    gcsfuse
    (writeShellScriptBin "deploy" ''
      export PATH=${lib.makeBinPath [ opentofu google-cloud-sdk ]};
      tofu -chdir=infrastructure init
      tofu -chdir=infrastructure apply -refresh-only
    '')
    (writeShellScriptBin "gpg-import-keys" ''
      export PATH=${lib.makeBinPath [ google-cloud-sdk pinentry gnupg ]};
      temp=$(mktemp -d)
      cleanup() {
        rm -rf "$temp" || true
      }
      trap cleanup EXIT
      gsutil rsync -r gs://dominicegginton/gpg "$temp"
      gpg --import "$temp"/*
    '')
  ];
  shellHook = ''
    gum confirm "Authenticate with GCP project ${gcpProject}?" && \
      gcloud auth application-default login && \
        gcloud config set project ${gcpProject} && \
          gum log --level info "Authenticated with GCP project ${gcpProject}."
  '';
}
