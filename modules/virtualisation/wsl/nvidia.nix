{
  lib,
  config,
  pkgs,
  ...
}:

{
  options.wsl.nvidia = {
    enable = lib.mkEnableOption "NVIDIA GPU on WSL (Windows driver + CUDA tooling)";
    docker = {
      enable = lib.mkEnableOption "NVIDIA Container Toolkit and CDI for Docker on WSL";
    };
  };

  config = lib.mkMerge [
    {
      wsl.nvidia.docker.enable = lib.mkDefault config.wsl.nvidia.enable;
    }

    (lib.mkIf (config.wsl.enable && config.wsl.nvidia.enable) {
      wsl.useWindowsDriver = lib.mkDefault true;
      environment.sessionVariables = {
        CUDA_PATH = "${pkgs.cudatoolkit}";
        EXTRA_LDFLAGS = "-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib";
        EXTRA_CCFLAGS = "-I/usr/include";
        LD_LIBRARY_PATH = lib.mkForce (
          lib.concatStringsSep ":" [
            "/usr/lib/wsl/lib"
            "${pkgs.linuxPackages.nvidia_x11}/lib"
          ]
        );
      };
      environment.systemPackages = [
        pkgs.cudatoolkit
      ];
    })

    (lib.mkIf (config.wsl.enable && config.wsl.nvidia.enable && config.wsl.nvidia.docker.enable) {
      hardware.nvidia-container-toolkit = {
        enable = lib.mkDefault true;
        mount-nvidia-executables = lib.mkDefault false;
        suppressNvidiaDriverAssertion = lib.mkDefault true;
      };
      systemd.services.nvidia-cdi-generator = {
        description = "Generate NVIDIA CDI spec for Docker";
        wantedBy = [ "docker.service" ];
        before = [ "docker.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart =
            "${pkgs.nvidia-docker}/bin/nvidia-ctk cdi generate"
            + " --output=/etc/cdi/nvidia.yaml"
            + " --nvidia-ctk-path=${pkgs.nvidia-container-toolkit}/bin/nvidia-ctk";
        };
      };
    })
  ];
}
