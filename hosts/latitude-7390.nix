{
  self,
  lib,
  config,
  platform,
  ...
}:

{
  nixpkgs.hostPlatform = lib.mkDefault platform;

  imports = with self.inputs.nixos-hardware.nixosModules; [
    common-pc-laptop
    common-pc-laptop-ssd
    dell-latitude-7390
  ];

  # TODO: move to disko configuration
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/591e8f6a-01bb-4a7b-8f9d-546400359853";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/5D74-0ED5";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  hardware.bluetooth.enable = true;
  hardware.intel-gpu-tools.enable = true;

  boot = {
    kernelModules = [
      "kvm-intel"
      "vhost_vsock"
      "i2c-dev"
      "ddcci_backlight"
    ];
    extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "usb_storage"
      "sd_mod"
    ];
  };

  # Enable Gnome desktop environment
  display.gnome.enable = true;

  # Enable Firefox web browser
  programs.firefox.enable = true;

  # Enable Flatpak for additional application installations
  services.flatpak.enable = true;

  # testing only, move to a server
  services.immich.enable = true;
  services.tsidp.enable = true;
  services.ollama = {
    enable = true;
    # Optional: preload models, see https://ollama.com/library
    loadModels = [
      "llama3.2:3b"
      "deepseek-r1:1.5b"
      "DeepSeek-Coder:6.7b"
    ];
  };
  services.open-webui.enable = true;

  # services.dit0 = {
  #   enable = true;
  #   base_dn = "dc=T2YHuJgy2121CNTRL,dc=com";
  #   ldap_port = 636;
  #   web_port = 443;
  #   data_dir = "/var/lib/dit0";
  #   otp_hmac_key_file = "/run/secrets/otp_hmac_key";
  #   tailscale = {
  #     id = "T2YHuJgy2121CNTRL";
  #     hostname = "dit0";
  #     api_base_url = "https://api.tailscale.com/api/v2";
  #     api_key_file = "/run/secrets/ts_api_key";
  #   };
  # };

  topology.self.hardware.info = "Workstation";
}
