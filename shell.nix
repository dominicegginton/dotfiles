{ lib
, mkShell
, nix
, nixpkgs-fmt
, deadnix
, nix-diff
, nix-tree
, opentofu
, google-cloud-sdk
, gcsfuse
, pinentry
, gnupg
, writeShellScriptBin
}:

let
  tempdir = "/tmp/dominicegginton";
in

mkShell {
  name = "dominicegginton/dotfiles";
  packages = [
    nix
    nixpkgs-fmt
    deadnix
    nix-diff
    nix-tree
    google-cloud-sdk
    gcsfuse
    opentofu
    (writeShellScriptBin "deploy" ''
      export PATH=${lib.makeBinPath [ google-cloud-sdk ]};
      gcloud auth application-default login
      tofu -chdir=infrastructure init
      tofu -chdir=infrastructure apply -refresh-only
    '')
    (writeShellScriptBin "gpg-import-keys" ''
      export PATH=${lib.makeBinPath [ google-cloud-sdk pinentry gnupg ]};
      temp=$(mktemp -d)
      cleanup() {
        rm -rf "$temp" || true
      }
      gcloud auth application-default login
      trap cleanup EXIT
      gsutil rsync -r gs://dominicegginton/gpg "$temp"
      gpg --import "$temp"/*
    '')
    (writeShellScriptBin "mount" ''
      export PATH=${lib.makeBinPath [ google-cloud-sdk gcsfuse ]};
      gcloud auth application-default login
      rm -rf ${tempdir} || true
      mkdir -p ${tempdir}
      gcsfuse --implicit-dirs dominicegginton ${tempdir}
    '')
    (writeShellScriptBin "unmount" ''
      export PATH=${lib.makeBinPath [ gcsfuse ]};
      fusermount -u ${tempdir} > /dev/null 2>&1 || true
      rm -rf ${tempdir} || true
    '')
  ];
  shellHook = ''
    cleanup() {
      unmount
    }
    trap cleanup EXIT
  '';
}
