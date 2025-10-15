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
, bws
}:

with lib;

mkShell rec {
  name = "github:" + lib.maintainers.dominicegginton.github + "/dotfiles";
  GCP_PROJECT_ID = "dominicegginton-personal";
  SECRET_KEYS_GCS_BUCKET = "dominicegginton/gpg";
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
    (writeShellScriptBin "deploy-new-machine" ''
      temp=$(mktemp -d)
      trap "rm -rf $temp" EXIT 
      install -d -m755 "$temp/etc/ssh"
      ## todo finish
    '')
    (writeShellScriptBin "create-new-machine-key" ''
      ## todo finish
    '')

    (writeShellScriptBin "sync-keys" ''
      temp=$(mktemp -d)
      trap "rm -rf $temp" EXIT
      mkdir -p "$temp/import"
      mkdir -p "$temp/export"
      gcloud config set project $GCP_PROJECT_ID || gum log --level error "Failed to set gcloud project to $GCP_PROJECT_ID."
      gsutil rsync gs://$SECRET_KEYS_GCS_BUCKET $temp/import || gum log --level error "Failed to sync GPG keys from GCS bucket $SECRET_KEYS_GCS_BUCKET." 
      for key in $(ls "$temp/import"); do
        gum log --level info "Importing GPG key $key for current user."
        gpg --import "$temp/import/$key" || gum log --level error "Failed to import GPG key $key."
        gum log --level info "Importing GPG key $key for root."
        sudo -u root bash -c "gpg --import '$temp/import/$key'" || gum log --level error "Failed to import GPG key $key for root."
        fingerprint=$(gpg --with-colons --fingerprint | grep fpr | head -n 1 | cut -d: -f10)
        gum log --level info "Trusting GPG key $key with fingerprint $fingerprint for current user."
        echo -e "5\ny\n" | gpg --command-fd 0 --expert --edit-key "$fingerprint" trust || gum log --level error "Failed to trust GPG key $key."
        gum log --level info "Trusting GPG key $key with fingerprint $fingerprint for root."
        sudo -u root bash -c "echo -e '5\ny\n' | gpg --command-fd 0 --expert --edit-key '$fingerprint' trust" || gum log --level error "Failed to trust GPG key $key for root."
        if gpg --list-secret-keys "$fingerprint" | grep -q "ssh"; then
          gum log --level info "Extracting SSH subkey for GPG key $key for current user."
          gpg --export-ssh-key "$fingerprint" > "$temp/$fingerprint.ssh" || gum log --level error "Failed to extract SSH subkey for GPG key $key."
          mkdir -p "$HOME/.ssh"
          cat "$temp/$fingerprint.ssh" >> "$HOME/.ssh/authorized_keys"
          chmod 600 "$HOME/.ssh/authorized_keys"
          gum log --level info "Extracting SSH subkey for GPG key $key for root."
          sudo -u root bash -c "gpg --export-ssh-key '$fingerprint' > '$temp/$fingerprint.ssh'" || gum log --level error "Failed to extract SSH subkey for GPG key $key for root."
          sudo -u root bash -c "mkdir -p '/root/.ssh'"
          sudo -u root bash -c "cat '$temp/$fingerprint.ssh' >> '/root/.ssh/authorized_keys'"
          sudo -u root bash -c "chmod 600 '/root/.ssh/authorized_keys'"
        else
          gum log --level info "No SSH subkey found for GPG key $key."
        fi
      done
      for key in $(gpg --list-secret-keys --keyid-format LONG | grep sec | awk '{print $2}' | cut -d/ -f2); do
        if gum confirm "Do you want to back up the GPG secret key $key for the current user?"; then
          gum log --level info "Exporting GPG key $key for the current user."
          gpg --export-secret-keys --armor "$key" > "$temp/export/$key.backup.asc" || gum log --level error "Failed to export GPG key $key."
          gsutil cp "$temp/export/$key.backup.asc" "gs://$SECRET_KEYS_GCS_BUCKET/$key.backup.asc" || gum log --level error "Failed to upload GPG key $key to gcloud."
          gum log --level info "Successfully uploaded GPG key $key to gcloud."
        else
          gum log --level info "Skipping backup of GPG key $key for the current user."
        fi
      done
      for key in $(sudo -u root gpg --list-secret-keys --keyid-format LONG | grep sec | awk '{print $2}' | cut -d/ -f2); do
        if gum confirm "Do you want to back up the GPG secret key $key for root?"; then
          gum log --level info "Exporting GPG key $key for root."
          sudo -u root bash -c "gpg --export-secret-keys --armor '$key' > '$temp/export/$key.backup.asc'" || gum log --level error "Failed to export GPG key $key for root."
          gsutil cp "$temp/export/$key.backup.asc" "gs://$SECRET_KEYS_GCS_BUCKET/$key.backup.asc" || gum log --level error "Failed to upload GPG key $key for root to gcloud."
          gum log --level info "Successfully uploaded GPG key $key for root to gcloud."
        else
          gum log --level info "Skipping backup of GPG key $key for root."
        fi
      done
      gum log --level info "GPG keys synchronized with GCS bucket $SECRET_KEYS_GCS_BUCKET."
    '')
    (writeShellScriptBin "sync-secrets" ''
      TEMP_DIR=$(mktemp -d)
      trap "rm -rf $TEMP_DIR" EXIT
      ${lib.getExe bws} secret list $BWS_PROJECT_ID \
        --output json \
        --access-token $BWS_ACCESS_TOKEN \
        > $TEMP_DIR/secrets.json
      ${lib.getExe gnupg} --encrypt \
        --recipient ${lib.maintainers.dominicegginton.email} \
        --recipient root@residence \
        --output secrets.json \
        $TEMP_DIR/secrets.json 
      ${lib.getExe gum} log --level info "Remember to commit and push the updated secrets.json file and switch to the new configuration on all host machines".
    '')
  ];
}
