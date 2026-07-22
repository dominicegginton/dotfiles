{
  self,
  lib,
  config,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.wsl.enable {
    # Apply the WSL overlay to add WSL-specific configurations and packages
    nixpkgs.overlays = [ self.outputs.overlays.wsl ];

    wsl = {
      # Default user for WSL environment
      defaultUser = "dom";

      # Use Windows drivers for better hardware compatibility and performance
      useWindowsDriver = lib.mkForce true;
    };

    # Enable Nvidia graphics driver configuration for the WSL host
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia.open = true;

    environment.sessionVariables = {
      CUDA_PATH = "${pkgs.cudatoolkit}";
      EXTRA_LDFLAGS = "-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib";
      EXTRA_CCFLAGS = "-I/usr/include";
      LD_LIBRARY_PATH = [
        "/usr/lib/wsl/lib"
        "${pkgs.linuxPackages.nvidia_x11}/lib"
        "${pkgs.ncurses5}/lib"
      ];
      MESA_D3D12_DEFAULT_ADAPTER_NAME = "Nvidia";
    };

    # Enable Nvidia Container Toolkit for GPU acceleration inside Docker
    hardware.nvidia-container-toolkit = {
      enable = true;
      mount-nvidia-executables = false;
    };

    # Automatically generate CDI specification for Nvidia Docker integration on boot / service startup
    systemd.services.nvidia-cdi-generator = {
      description = "Generate nvidia CDI specification";
      wantedBy = [ "docker.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.nvidia-docker}/bin/nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml --nvidia-ctk-path=${pkgs.nvidia-container-toolkit}/bin/nvidia-ctk";
      };
    };

    # Configure Docker daemon to leverage Container Device Interface (CDI) specs
    virtualisation.docker = {
      daemon.settings = {
        features.cdi = true;
        cdi-spec-dirs = [ "/etc/cdi" ];
      };
    };

    environment.systemPackages = with pkgs; [
      jetbrains.gateway
      nodejs
      typescript
    ];

    # Disable kernel module locking in WSL as it prevents Docker port mapping
    security.lockKernelModules = lib.mkForce false;
    security.protectKernelImage = lib.mkForce false;

    # Enable nix-ld to run unpatched Linux binaries
    programs.nix-ld.enable = lib.mkForce true;

    security.run0.enable = lib.mkForce false;
    security.sudo.wheelNeedsPassword = lib.mkForce false;
    users.users.dom = {
      hashedPasswordFile = lib.mkForce null;
      initialPassword = "";
    };

    # Disable security services not applicable to WSL
    programs.deadman.enable = lib.mkForce false;
    services.usbguard.enable = lib.mkForce false;

    services = {
      # Disable thermal and power management not required in WSL
      thermald.enable = lib.mkForce false;
      upower.enable = lib.mkForce false;

      # Disable firmware updates
      fwupd.enable = lib.mkForce false;

      # Disable storage maintenance for virtualized disks
      fstrim.enable = lib.mkForce false;
      smartd.enable = lib.mkForce false;
    };

    networking.wireless.enable = lib.mkForce false;

    # Avoid boot/login delays from network-online waits in virtualized WSL networking.
    systemd.services = {
      NetworkManager-wait-online.enable = lib.mkForce false;
      systemd-networkd-wait-online.enable = lib.mkForce false;
      # Supplicant is not used in WSL and may fail when no Wi-Fi device exists.
      wpa_supplicant.enable = lib.mkForce false;
    };

    boot = {
      loader = {
        systemd-boot.enable = lib.mkForce false;
        efi.canTouchEfiVariables = lib.mkForce false;
      };

      # Disable Plymouth bootloader splash screen in WSL.
      plymouth.enable = lib.mkForce false;
    };
  };
}
