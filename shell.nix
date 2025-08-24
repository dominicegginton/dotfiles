{ lib
, mkShell
, writeShellScriptBin
, nix
, nix-output-monitor
, nixpkgs-fmt
, deadnix
, nix-diff
, nix-tree
, nix-health
, nix-index
, clamav
, google-cloud-sdk
, opentofu
, coreutils
, gum
, jq
, gnupg
}:

mkShell rec {
  name = "github:" + lib.maintainers.dominicegginton.github + "/dotfiles";
  packages = [
    nix
    nix-output-monitor
    nixpkgs-fmt
    deadnix
    nix-diff
    nix-tree
    nix-health
    nix-index
    clamav
    google-cloud-sdk
    opentofu
    coreutils
    gum
    jq
    gnupg
    (writeShellScriptBin "deploy" ''
      gcloud auth login
      tofu -chdir=infrastructure init
      tofu -chdir=infrastructure apply -refresh-only
    '')
    (writeShellScriptBin "gpg-import-keys" ''
      temp=$(mktemp -d)
      cleanup() {
        gum log --level info "Cleaning up temporary directory $temp."
        rm -rf "$temp" || true
      }
      trap cleanup EXIT
      gcloud auth login
      gsutil rsync gs://dominicegginton/gpg $temp
      for key in $(ls "$temp"); do
        gum log --level info "Importing GPG key $key."
        gpg --import "$temp/$key" || gum log --level error "Failed to import GPG key $key."
      done
      gum log --level info "Successfully imported GPG keys."
    '')
  ];
}
