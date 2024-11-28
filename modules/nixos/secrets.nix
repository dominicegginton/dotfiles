{ config, lib, pkgs, BW, ... }:

with lib;

let
  bitwarden-secret = builtins.readFile BW.outPath;
  op_tmp_dir = "/root/op_tmp";
  op_cfg_dir = "/root/.config/op";
  chownGroup = "keys";
  secretsDir = "/run/secrets";
  mountPoint = "/run/secrets.d";
  secrets = config.modules.secrets;

  # fixes permissions issues with op session files
  createTmpDirShim = ''
    rm -rf ${op_tmp_dir}
    mkdir -p ${op_tmp_dir}
    chmod 600 ${op_tmp_dir}
  '';

  chmodOpSessionFiles = ''
    for i in $(${pkgs.findutils}/bin/find ${op_tmp_dir} -type f); do
      chmod 600 "$i"
    done
  '';
  createOpConfigDir = ''
    mkdir -p ${op_cfg_dir}
    chmod 700 ${op_cfg_dir}
    if [ ! -f ${op_cfg_dir}/config ] || [ ! -s ${op_cfg_dir}/config ]; then
      echo "{}" > ${op_cfg_dir}/config
    fi
    chmod 600 ${op_cfg_dir}/config
  '';
  mountCommand = ''
    grep -q "${mountPoint}" /proc/mounts ||
      ${pkgs.util-linux}/bin/mount -t ramfs none ${mountPoint} -o nodev,nosuid,mode=0751
  '';
  setSecretsGeneration = ''
    _secrets_generation="$(basename "$(readlink ${secretsDir})" || echo 0)"
  '';

  newGeneration = ''
    ${setSecretsGeneration}
    (( ++_secrets_generation ))
    mkdir -p "${secretsDir}"
    chmod 0751 "${secretsDir}"
    ${mountCommand}
    mkdir -p "${mountPoint}/$_secrets_generation"
    chmod 0751 "${mountPoint}/$_secrets_generation"
  '';

  # chown the secrets mountpoint and the current generation to the keys group
  # instead of leaving it root:root.
  chownMountPoint = ''
    chown ${chownGroup} ${secretsDir} "${mountPoint}/$_secrets_generation"
  '';

  cleanupAndLink = ''
    ln -sfT "${mountPoint}/$_secrets_generation" "${secretsDir}"
    (( _secrets_generation > 1 )) && {
      rm -rf "${mountPoint}/$(( _secrets_generation - 1 ))"
    }
  '';

  setTruePath = secret: ''
    truePath="/run/secrets.d/$_secrets_generation/${secret}"
  '';
  chownSecret = secret: ''
    ${setTruePath secret}
    chown 0:0 "$_truePath"
  '';
  chownSecrets = builtins.concatStringsSep "\n"
    ([ chownMountPoint ] ++ (map chownSecret (builtins.attrValues secrets)));

  installSecret = secret: ''
    ${chmodOpSessionFiles}
    ${setTruePath secret}
    TMP_FILE="$_truePath.tmp"
    mkdir -p "$(dirname "$_truePath")"
    [ "${secret}" != "${secretsDir}/${secret}" ] && mkdir -p "$(dirname "${secret}")"
    (
      umask u=r,g=,o=
      test -d "$(dirname "$TMP_FILE")" || echo "[secrets] WARNING: $(dirname "$TMP_FILE") does not exist!"
      set -x
      TMPDIR="${op_tmp_dir}" ${pkgs.bitwarden-cli}/bin/bw get item "${secret}" --raw | base64 -d > "$TMP_FILE"
    )
    chmod 0400 "$TMP_FILE"
    mv -f "$TMP_FILE" "$_truePath"
  '';

  script = ''
    echo "[secrets] provisioning secrets..."
    ${createOpConfigDir}
    ${createTmpDirShim}
    ${newGeneration}
    ${builtins.concatStringsSep "\n" (map installSecret (builtins.attrValues cfg.secrets))}
    ${cleanupAndLink}
    ${chownSecrets}
  '';
in

{

  options.modules.secrets = mkOption {
    type = types.attrsOf types.string;
    default = { };
    description = ''
      A map of secrets.
    '';
  };

  config = {

    systemd.services.secrets = {
      wants = [ "network-online.target" ];
      after = [ "network.target" "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        StandardOutput = "null";
        StandardError = "null";
        EnvironmentFile = BW;
      };

      script = script;
    };

    system.activationScripts.secrets = {
      # if no generation already exists, rely on the systemd startup job;
      # otherwise, if there already is an existing generation, reprovision
      # secrets because we did a nixos-rebuild
      text = ''
        ${scripts.setOpnixGeneration}
        (( _opnix_generation > 1 )) && {
          source ${cfg.environmentFile}
          export OP_SERVICE_ACCOUNT_TOKEN
          ${script}
        }
      '';
      deps = [ "usrbinenv" ];
    };
  };
}
