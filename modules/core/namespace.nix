{ config, lib, pkgs, tailnet, ... }:

let
  plan9Root = "/srv/plan9";
in
{
  boot.kernelModules = [ "9p" "9pnet_virtio" "9pnet_tcp" ];
  boot.supportedFilesystems = [ "9p" "overlay" ];

  systemd.tmpfiles.rules = [
    "d ${plan9Root} 0755 root root -"
    "d ${plan9Root}/net 0755 root root -"
    "d ${plan9Root}/services 0755 root root -"
    "d ${plan9Root}/builds 0755 root root -"
    "d ${plan9Root}/apps 0755 root root -"
    "d ${plan9Root}/storage 0755 root root -"
    "d ${plan9Root}/namespace 0755 root root -"
    "d ${plan9Root}/services/cache 0755 root root -"
    "d ${plan9Root}/apps/default 0755 root root -"
  ];

  fileSystems."/mnt/remote-store" = lib.mkIf (config.networking.hostName != "ghost-gs60") {
    device = "ghost-gs60.${tailnet}";
    fsType = "9p";
    options = [
      "trans=tcp"
      "port=5640"
      "msize=262144"
      "cache=loose"
      "nofail"
    ];
  };

  fileSystems."${plan9Root}/storage/remote-store" = lib.mkIf (config.networking.hostName != "ghost-gs60") {
    device = "ghost-gs60.${tailnet}";
    fsType = "9p";
    options = [
      "trans=tcp"
      "port=5640"
      "msize=262144"
      "cache=loose"
      "nofail"
    ];
  };

  systemd.services.setup-overlay-namespaces = {
    description = "Configure Plan 9 style overlay namespaces";
    wantedBy = [ "multi-user.target" ];
    script = ''
      mkdir -p /run/namespaces
      mkdir -p ${plan9Root}/net ${plan9Root}/services ${plan9Root}/builds ${plan9Root}/apps ${plan9Root}/storage ${plan9Root}/namespace
      mkdir -p ${plan9Root}/services/cache ${plan9Root}/apps/default ${plan9Root}/storage/remote-store
      ln -sfn ${plan9Root}/storage/remote-store ${plan9Root}/namespace/remote-store
      ln -sfn ${plan9Root}/services ${plan9Root}/namespace/services
      ln -sfn ${plan9Root}/builds ${plan9Root}/namespace/builds
      ln -sfn ${plan9Root}/apps ${plan9Root}/namespace/apps
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
