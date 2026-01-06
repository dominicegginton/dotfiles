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
, google-cloud-sdk
, opentofu
, coreutils
, gum
, jq
, gnupg
, bws
, qrencode
}:

let
  GCP_PROJECT_ID = builtins.getEnv "GCP_PROJECT_ID";
  BWS_PROJECT_ID = builtins.getEnv "BWS_PROJECT_ID";
  BWS_ACCESS_TOKEN = builtins.getEnv "BWS_ACCESS_TOKEN";
in

assert GCP_PROJECT_ID != "";
assert BWS_PROJECT_ID != "";
assert BWS_ACCESS_TOKEN != "";

mkShell rec {
  name = "github:" + lib.maintainers.dominicegginton.github + "/dotfiles";
  keys = [ "root@dominicegginton.dev" ];

  inherit GCP_PROJECT_ID BWS_PROJECT_ID BWS_ACCESS_TOKEN;

  packages = [
    nix
    nix-output-monitor
    nixpkgs-fmt
    deadnix
    nix-diff
    nix-tree
    nix-health
    nix-index
    google-cloud-sdk
    opentofu
    coreutils
    gum
    jq
    gnupg
    qrencode
    (writeShellScriptBin "advertise-ssh" ''
      root_password=$(openssl rand -base64 32)
      echo "Root password: $root_password" | qrencode -t ANSIUTF8
    '')
    (writeShellScriptBin "sync-secrets" ''
      TEMP_DIR=$(mktemp -d)
      trap "rm -rf $TEMP_DIR" EXIT
      ${lib.getExe bws} secret list $BWS_PROJECT_ID \
        --output json \
        --access-token $BWS_ACCESS_TOKEN \
        > $TEMP_DIR/secrets.json
      ${lib.getExe gnupg} --encrypt \
        ${toString (map (key: "--recipient " + key) keys)} \
        --output secrets.json \
        $TEMP_DIR/secrets.json
    '')
  ];

  meta.maintainers = [ lib.maintainers.dominicegginton ];
}
