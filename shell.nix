{ lib
, mkShell
, nix
, nix-output-monitor
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
, jq
}:

let
  tempdir = "/tmp/dominicegginton";
  gcp.project = "dominicegginton-personal";
  gcp.bucket = "gs://dominicegginton";
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
    jq
    ## todo: finish this script
    (writeShellScriptBin "create-bootable-usb" ''
      target=$(gum choose --cursor "Select the target device" $(lsblk -d -n -p -o NAME,SIZE | grep -v loop | awk '{print $1}'))
      nom build github:dominicegginton/dotfiles#nixosConfigurations.nixos-installer.config.system.build.isoImage
      source=$(jq -r '.[] | select(.path | contains("result")) | .path' | head -n 1)
      gum confirm "Are you sure you want to write $source to $target?" && \
        sudo dd if="$source" of="$target" bs=4M status=progress && \
          gum log --level info "Successfully wrote $source to $target."
      gum confirm "Do you want to sync the filesystem?" && \
        sudo sync && \
          gum log --level info "Successfully synced the filesystem."
      gum confirm "Do you want to eject the device?" && \
        sudo eject "$target" && \
          gum log --level info "Successfully ejected $target."
    '')
    (writeShellScriptBin "deploy" ''
      gcloud auth application-default login && gcloud config set project ${gcp.project}
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
      gsutil rsync gs://dominicegginton/gpg $temp
      gum log --level info "Importing GPG keys from $temp."
      for key in $(ls "$temp"); do
        gum log --level info "Importing GPG key $key."
        gpg --import "$temp/$key" || gum log --level error "Failed to import GPG key $key."
      done
      gum log --level info "Successfully imported GPG keys."
    '')
  ];
}
