{
  self,
  lib,
  mkShell,
  writeShellScriptBin,
  nix,
  nix-output-monitor,
  deadnix,
  nix-diff,
  nix-tree,
  nix-health,
  nix-index,
  google-cloud-sdk,
  opentofu,
  gum,
  jq,
  gnupg,
  # bws,
  neovim,
  disko,
}:

mkShell rec {
  name = "github:" + lib.maintainers.dominicegginton.github + "/dotfiles";
  keys = [ "root@dominicegginton.dev" ];

  GCP_PROJECT_ID = builtins.getEnv "GCP_PROJECT_ID";
  BWS_PROJECT_ID = builtins.getEnv "BWS_PROJECT_ID";
  BWS_ACCESS_TOKEN = builtins.getEnv "BWS_ACCESS_TOKEN";

  packages = [
    nix
    nix-output-monitor
    deadnix
    nix-diff
    nix-tree
    nix-health
    nix-index
    google-cloud-sdk
    opentofu
    # (writeShellScriptBin "sync-secrets" ''
    #   TEMP_DIR=$(mktemp -d)
    #   trap "rm -rf $TEMP_DIR" EXIT
    #   ${lib.getExe bws} secret list $BWS_PROJECT_ID \
    #     --output json \
    #     --access-token $BWS_ACCESS_TOKEN \
    #     > $TEMP_DIR/secrets.json
    #   ${lib.getExe gnupg} --encrypt \
    #     ${toString (map (key: "--recipient " + key) keys)} \
    #     --output secrets.json \
    #     $TEMP_DIR/secrets.json
    # '')

    # TODO: complete (define a common schema in the screts module and use it both here and in systemd secret decryption service)
    (writeShellScriptBin "open-secrets" ''
      TEMP_DIR=$(mktemp -d)
      trap "rm -rf $TEMP_DIR" EXIT
      ${lib.getExe gnupg} --decrypt \
        --output $TEMP_DIR/secrets.json \
        secrets.json
      ${lib.getExe neovim} $TEMP_DIR/secrets.json
      if ! ${lib.getExe jq} -e 'all(.[]; has("name") and has("value") and (.name | type == "string") and (.value | type == "string"))' $TEMP_DIR/secrets.json > /dev/null; then
        ${lib.getExe gum} log --level error "Invalid secrets.json schema. Aborting encryption."
        exit 1
      fi
      ${lib.getExe gnupg} --encrypt \
        ${toString (map (key: "--recipient " + key) keys)} \
        --output secrets.json \
        $TEMP_DIR/secrets.json
    '')

    # script to be run from an installer iso to bootstrap a new system
    (writeShellScriptBin "bootstrap-system" ''
      set -euo pipefail

      ${lib.getExe gum} log "Starting system bootstrap..."

      # the root private gpg key is first arg
      # TODO:
      ROOT_GPG_KEY=""

      # run disko to partition and format disks and install nixos
      ${lib.getExe gum} log "Running disko to partition and format disks..."

      # TODO: implement
      DISK="/dev/sda"  # default disk
      CONFIG="latitude-7390"  # default config

      exec ${disko}/bin/disko-install --flake "${self}#$CONFIG" --write-efi-boot-entries --disk main "$DISK"

      # chroot into the new system and import the root gpg key
      ${lib.getExe gum} log "Importing root GPG key into new system..."
      # TODO: implement

      ${lib.getExe gum} log "System bootstrap complete."
    '')
  ];

  meta.maintainers = [ lib.maintainers.dominicegginton ];
}
