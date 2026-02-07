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
  ];

  meta.maintainers = [ lib.maintainers.dominicegginton ];
}
