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
, writers
, bws
}:

with lib;

mkShell rec {
  name = "github:" + lib.maintainers.dominicegginton.github + "/dotfiles";
  BWS_PROJECT_ID = "3669bedc-9534-475e-83f6-b2410091e1c2";
  BWS_ACCESS_TOKEN = builtins.getEnv "BWS_ACCESS_TOKEN";
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
        gum log --level info "Importing GPG key $key for root."
        sudo -u root bash -c "gpg --import '$temp/$key'" || gum log --level error "Failed to import GPG key $key for root."
      done
      gum log --level info "Successfully imported GPG keys."
    '')
    (writeShellScriptBin "sync-secrets" ''
      TEMP_DIR=$(mktemp -d)
      trap "rm -rf $TEMP_DIR" EXIT
      ${lib.getExe bws} secret list $BWS_PROJECT_ID \
        --output json \
        --access-token $BWS_ACCESS_TOKEN \
        > $TEMP_DIR/secrets.json
      ${lib.getExe gnupg} --encrypt \
        --recipient dominic.egginton@gmail.com \
        --output secrets.json \
        $TEMP_DIR/secrets.json 
      ${lib.getExe gum} log --level info "Secrets synchronized and encrypted to secrets.json."
    '')
  ];
}
