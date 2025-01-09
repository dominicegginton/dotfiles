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

    wrtie_secrets_env() {
      BWS_PROJECT_ID=$(gum input --password --prompt "Bitwarden Secrets Project ID: " --placeholder "********")
      BWS_ACCESS_TOKEN=$(gum input --password --prompt "Bitwarden Secrets Access Token: " --placeholder "********")
      echo "BWS_PROJECT_ID=$BWS_PROJECT_ID" > ${directory}/secrets.env
      echo "BWS_ACCESS_TOKEN=$BWS_ACCESS_TOKEN" >> ${directory}/secrets.env
      gum log --level info "${directory}/secrets.env created"
    }

    if [ -f ${directory}/secrets.env ]; then
      gum confirm "${directory}/secrets.env already exists. Overwrite? (y/n)" && wrtie_secrets_env
    else
      wrtie_secrets_env
    fi
    source ${directory}/secrets.env

    export BWS_PROJECT_ID
    export BWS_ACCESS_TOKEN

    gum spin \
      --show-output \
      --title "Syncing secrets from Bitwarden Secrets $BWS_PROJECT_ID" \
      -- bws secret list "$BWS_PROJECT_ID" \
        --output json \
        --access-token "$BWS_ACCESS_TOKEN" \
        > ${directory}/secrets.json

    if [ ! -f ${directory}/secrets.json ]; then gum log --level error "Failed to create ${directory}/secrets.json"; exit 1; fi
    secret_ids=$(jq -r '.[] | .id' ${directory}/secrets.json)
    ids=$(gum choose --no-limit $secret_ids)
    for id in $ids; do
      name=$(jq -r ".[] | select(.id == \"$id\") | .key" ${directory}/secrets.json)
      value=$(jq -r ".[] | select(.id == \"$id\") | .value" ${directory}/secrets.json)
      if [ -z "$name" ] || [ -z "$value" ]; then continue; fi
      echo $value | sed 's/\\n/\n/g' > ${directory}/secrets/$name
      chown root:root ${directory}/secrets/$name
      chmod 600 ${directory}/secrets/$name
      ln -sf ${directory}/secrets/$name ${mount}/$name
      chown root:root ${mount}/$name
      chmod 600 ${mount}/$name
      gum log --level info "Synced secret $name"
    done
  ''
