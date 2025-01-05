{ lib, stdenv, writers, ensure-user-is-root, busybox, gum, jq, bws, ... }:

if (!stdenv.isLinux)
then throw "This script can only be run on linux hosts"
else

  let
    directory = "/root/bitwarden-secrets";
    mount = "/run/bitwarden-secrets";
  in

  writers.writeBashBin "secrets-sync" ''
    export PATH=${lib.makeBinPath [ ensure-user-is-root busybox gum jq bws ]}
    set -efu -o pipefail
    ensure-user-is-root
    BWS_PROJECT_ID=$(gum input --password --prompt "Bitwarden Secrets Project ID: " --placeholder "********")
    BWS_ACCESS_TOKEN=$(gum input --password --prompt "Bitwarden Secrets Access Token: " --placeholder "********")
    gum spin --show-output --title "Syncing Secrets" \
      -- bws secret list "$BWS_PROJECT_ID" --output json --access-token "$BWS_ACCESS_TOKEN" > ${directory}/secrets.json
    secret_ids=$(q -r '.[] | .id' ${directory}/secrets.json)
    for id in $secret_ids; do
      name=$(jq -r ".[] | select(.id == \"$id\") | .key" ${directory}/secrets.json)
      value=$(jq -r ".[] | select(.id == \"$id\") | .value" ${directory}/secrets.json)
      if [ -z "$name" ] || [ -z "$value" ]; then
        continue
      fi
      echo $value | sed 's/\\n/\n/g' > ${directory}/secrets/$name
      chown root:root ${directory}/secrets/$name
      chmod 600 ${directory}/secrets/$name
      ln -sf ${directory}/secrets/$name ${mount}/$name
      chown root:root ${mount}/$name
      chmod 600 ${mount}/$name
      gum log --level info "Synced secret $name"
    done
  ''
