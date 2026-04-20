# Host: Walsgrave Server
# Simple host configuration header
{
  self,
  lib,
  platform,
  hostname,
  ...
}:

{
  nixpkgs.hostPlatform = lib.mkDefault platform;

  imports = with self.inputs.nixos-hardware.nixosModules; [ ];

  hardware.disks.device = "/dev/sda";
  hardware.disks.swapSize = "16G";

  # OIDC / OAuth Identity Provider (IdP)
  services.tsidp.enable = true;

  # Photos/Video Management
  services.immich.enable = true;

  # LLM AI Services
  services.ollama.enable = true;

  # LLM AI Web Interface
  services.open-webui.enable = true;

  # Directory Information Tree & LDAP Services
  # services.dit0.enable = true;

  # NVR & OD Services
  services.frigate = {
    enable = true;
    settings = {
      cameras = {
        "Frontdoor".ffmpeg.inputs = [
          {
            path = "rtsp://frigate:frigate123@192.168.1.226:554/Preview_01_main";
            roles = [ "record" ];
          }
          {
            path = "rtsp://frigate:frigate123@192.168.1.226:554/Preview_01_sub";
            roles = [ "detect" ];
          }
        ];
      };
    };
  };

  # Notes Services
  services.silverbullet.enable = true;

  # Topology Definition
  topology.self = {
    hardware.info = "Walsgrave Server";

    # Connection Directly
    interfaces.eth0 = {
      network = "ribble";
      type = "ethernet";
      addresses = [ hostname ];
    };
  };
}
