{
  config,
  lib,
  tailnet,
  pkgs,
  ...
}:

{
  options.services.silverbullet.bucketName = lib.mkOption {
    type = lib.types.str;
    description = "The name of the GCS bucket to use for Silverbullet storage.";
  };

  config = lib.mkIf config.services.silverbullet.enable {
    systemd.services.silverbullet-gcsfuse = {
      description = "Mount Silverbullet GCS bucket";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      before = [ "silverbullet.service" ];
      wantedBy = [ "silverbullet.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
      };
      script = ''
        export PATH=${
          lib.makeBinPath [
            pkgs.gcsfuse
            pkgs.coreutils
          ]
        }:$PATH

        if ${pkgs.coreutils}/bin/mountpoint -q "${config.services.silverbullet.spaceDir}"; then
          ${pkgs.coreutils}/bin/umount "${config.services.silverbullet.spaceDir}"
        fi

        rm -rf "${config.services.silverbullet.spaceDir}"
        mkdir -p "${config.services.silverbullet.spaceDir}"

        exec ${pkgs.gcsfuse}/bin/gcsfuse \
          --implicit-dirs \
          --file-mode=0775 \
          --dir-mode=0775 \
          --uid $(id -u ${config.services.silverbullet.user}) \
          --gid $(id -g ${config.services.silverbullet.user}) \
          "${config.services.silverbullet.bucketName}" \
          "${config.services.silverbullet.spaceDir}"
      '';
    };

    services.silverbullet = {
      listenAddress = "0.0.0.0";
      listenPort = 8765;
      openFirewall = lib.mkDefault false;
      user = lib.mkDefault "silverbullet";
      bucketName = lib.mkDefault "immich-data-66ea520add6c51fb";
      spaceDir = lib.mkDefault "/var/lib/silverbullet";
    };

    services.tailscale.serve = {
      enable = true;
      services."silverbullet".endpoints."tcp:443" =
        "https+insecure://127.0.0.1:${builtins.toString config.services.silverbullet.listenPort}";
    };

    topology.self.services.silverbullet = {
      name = "Silverbullet";
      details.listen.text = "https://silverbullet.${tailnet}";
    };
  };
}
