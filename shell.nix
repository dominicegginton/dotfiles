{ lib
, mkShell
, nix
, nix-output-monitor
, nixpkgs-fmt
, deadnix
, nix-diff
, nix-tree
, nix-health
, google-cloud-sdk
, gcsfuse
, opentofu
, coreutils
, gum
, jq
, pinentry
, gnupg
, writeShellScriptBin
}:

let
  gcp.project = "dominicegginton-personal";
  gcp.bucket = "gs://dominicegginton";
in

mkShell rec {
  name = lib.maintainers.dominicegginton.github + "/dotfiles";
  packages = [
    nix
    nix-output-monitor
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
    jq
    pinentry
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
      gum log --level info "Copying GPG keys from GCP bucket ${gcp.bucket}/gpg to $temp."
      gsutil rsync ${gcp.bucket}/gpg $temp
      gum log --level info "Importing GPG keys from $temp."
      for key in $(ls "$temp"); do
        gum log --level info "Importing GPG key $key."
        gpg --import "$temp/$key" || gum log --level error "Failed to import GPG key $key."
      done
      gum log --level info "Successfully imported GPG keys."
    '')
    (writeShellScriptBin "bootstrap-nixos-installer" ''
      source=$(nom build github:${name}#nixosConfigurations.nixos-installer.config.system.build.isoImage --no-link --json | jq -r '.[] | select(.outputs.out) | .outputs.out' | head -n 1)
      target=$(gum choose --cursor "Select the target device" $(lsblk -d -n -p -o NAME,SIZE | grep -v loop | awk '{print $1}'))
      gum confirm "Are you sure you want to write $source to $target?" && \
        sudo dd if="$source" of="$target" bs=4M status=progress && \
          gum log --level info "Successfully wrote $source to $target."
    '')
  ];
}
