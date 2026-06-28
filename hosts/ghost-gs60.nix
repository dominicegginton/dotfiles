{
  self,
  config,
  lib,
  hostname,
  platform,
  ...
}:

{
  # Set host platform
  nixpkgs.hostPlatform = lib.mkDefault platform;

  # Hardware-specific modules
  imports = with self.inputs.nixos-hardware.nixosModules; [
    common-pc-laptop
    common-pc-laptop-ssd
    common-pc-laptop-hdd
    msi-gs60
  ];

  services.onlyoffice-documentserver = {
    enable = true;
    hostname = "office.ghost-gs60.local";
    jwtSecretFile = config.sops.secrets."onlyoffice_jwt_secret".path;
  };

  services.oauth2-proxy = {
    enable = true;
    upstream = "http://127.0.0.1:${toString config.services.onlyoffice-documentserver.port}";
    oidcIssuerUrl = "https://oidc.tailnet.ts.net"; # Placeholder, replace with actual OIDC issuer
    oidcClientId = "onlyoffice";
    oidcClientSecretFile = config.sops.secrets."oauth2_proxy_oidc_client_secret".path;
    oidcRedirectUrl = "https://office.ghost-gs60.local/oauth2/callback";
    oidcScopes = [
      "openid"
      "profile"
      "email"
    ];
    cookieSecretFile = config.sops.secrets."oauth2_proxy_cookie_secret".path;
    jwtUpstreamEnable = true;
    jwtUpstreamSecretFile = config.sops.secrets."onlyoffice_jwt_secret".path;
    jwtUpstreamHeader = "X-WOPI-Signature-Key";
    nginx.virtualHosts."office.ghost-gs60.local" = {};
  };

  services.tailscale.serve = {
    enable = true;
    services = {
      onlyoffice = {
        hosts = [ "office.ghost-gs60.local" ];
        localPort = 80;
        # Assuming oauth2-proxy handles HTTPS internally with Tailscale
        # proto = "https";
      };
    };
  };

  services.postgresql.enable = true;
  services.rabbitmq.enable = true;

  # Disko configuration for storage layout
  disko.devices = {
    disk = {
      main = {
        device = "/dev/sdb";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # EFI System Partition
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "128M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            # Btrfs root partition
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                mountpoint = "/";
                mountOptions = [ "noatime" ];
              };
            };
          };
        };
      };
      extra = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                mountpoint = "/mnt/data";
                mountOptions = [ "noatime" ];
              };
            };
          };
        };
      };
    };
  };
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "usb_storage"
    "sd_mod"
    "sr_mod"
  ];

  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  programs.deadman.enable = false; # Disable deadman switch.

  # Ignore events from the lid switch
  services.logind.settings.Login.HandleLidSwitch = "ignore";
  services.upower.ignoreLid = true;

  # Enable Tailscale Identity Provider (IdP)
  services.tsidp.enable = true;

  # Enable Beszel monitoring (Hub and Agent)
  services.beszel.hub.enable = true;

  # Enable Immich Photos/Video Management Services
  services.immich.enable = true;

  # Enable Jellyfin Media Server Services
  services.jellyfin.enable = true;

  # Enable Frigate NVR & OD Services
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

  # Enable SilverBullet Notes Services
  services.silverbullet.enable = true;

  # Topology Definition
  topology.self = {
    hardware.info = "MSI Ghost GS60";

    # Network Interface Configuration
    interfaces.eth0 = {
      network = "ribble";
      type = "ethernet";
      addresses = [ hostname ];
      physicalConnections = [ (config.lib.topology.mkConnection "switch" "eth3") ];
    };
  };
}
