{ inputs, modulesPath, config, lib, pkgs, nixConfig, ... }:

rec {
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
    ./display/gnome.nix
    ./display/niri.nix
    ./display/steamos.nix
    ./hardware/bluetooth.nix
    ./hardware/disks.nix
    ./programs/alacritty.nix
    ./programs/chromium.nix
    ./programs/firefox.nix
    ./programs/sherlock-launcher.nix
    ./programs/steam.nix
    ./programs/vscode.nix
    ./programs/zsh.nix
    ./services/calmav.nix
    ./services/davfs2.nix
    ./services/flatpak.nix
    ./services/frigate.nix
    ./services/home-assistant.nix
    ./services/mosquitto.nix
    ./services/pipewire.nix
    ./services/printing.nix
    ./services/silverbullet.nix
    ./services/tailscale.nix
    ./services/tlp.nix
    ./services/unifi.nix
    ./services/zabbix.nix
    ./virtualisation/virtualisation.nix
    ./virtualisation/docker.nix
    ./virtualisation/waydroid.nix
    ./backup.nix
    ./console.nix
    ./environment.nix
    ./networking.nix
    ./secrets.nix
    ./upgrade.nix
    ./users.nix
  ];

  system = {
    # state version for nixos modules
    stateVersion = config.system.nixos.release;

    # custom distro metadata
    nixos = {
      distroName = lib.mkDefault "Residence";
      distroId = lib.mkDefault "residence";
      vendorName = lib.mkDefault pkgs.lib.maintainers.dominicegginton.name;
      vendorId = lib.mkDefault pkgs.lib.maintainers.dominicegginton.github;
      tags = [ (lib.optionalString (pkgs.stdenv.isLinux) "residence-linux") ];
    };
  };

  # system color scheme
  scheme = "${pkgs.theme}/residence-theme.yaml";

  # system time zone
  time.timeZone = "Europe/London";

  # system locale
  i18n.defaultLocale = "en_GB.UTF-8";

  # nix settings
  nix = {
    # nix pkg
    package = pkgs.nix;

    # automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # automatic optimise of the nix store
    optimise.automatic = lib.mkDefault true;

    # disable channel updates
    channel.enable = false;

    # nix registry entries
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    # nix settings
    settings = nixConfig // {
      # garbage collection settings
      min-free-check-interval = 1;

      # disable global registry
      flake-registry = "";

      # performance optimizations for faster rebuilds
      keep-outputs = true; # keep build outputs
      keep-derivations = true; # keep derivations for faster rebuilds

      # performance settings
      eval-cache = true; # enable caching
      narinfo-cache-positive-ttl = 3600; # longer cache for existing narinfos
      narinfo-cache-negative-ttl = 60; # quicker retries on missing narinfo
      fsync-metadata = false; # faster on SSDs
      connect-timeout = 10; # faster timeouts
      max-substitution-jobs = 128; # increased parallel substitutions
      http-connections = 128; # increased parallel connections
      cores = 0; # use all available CPU cores
      max-jobs = "auto"; # use all available CPU cores

      # redunce storage overhead
      keep-build-log = false; # dont keep build logs
      compress-build-log = true; # compress build logs

      # trusted users for nix commands
      trusted-users = [
        "root" # machine root user
        "@wheel" # admin group
      ];
    };
  };

  boot = {
    consoleLogLevel = 0; # log all boot messages
    initrd.verbose = false; # disable verbose initrd
    loader = {
      systemd-boot.enable = true; # enable systemd-boot
      efi.canTouchEfiVariables = true; # allow efi variables modification
    };

    plymouth = {
      enable = true;
      themePackages = [ pkgs.plymouth-theme ]; # boot theme package
      theme = "colorful"; # set boot theme
    };
  };

  documentation = {
    enable = true;
    man.enable = true;
    doc.enable = true;
    dev.enable = true;
    info.enable = true;
  };

  programs = {
    # enable gpg agent for managing gpg keys
    gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry; # use default pinentry
    };

    # enable ssh agent for managing ssh keys
    ssh.startAgent = true;

    # suggest commands when command is not found
    command-not-found.enable = true;
  };

  # enable microcode updates for intel/amd cpus
  hardware.cpu = {
    intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  # virtualisation settings for machine images
  virtualisation.vmVariant.users = {

    # setup a usergroup for the test user
    groups.nixosvmtest = { };

    # setup the test user
    users.nix = {
      description = "NixOS VM Test User";
      isNormalUser = true;
      initialPassword = "";
      group = "nixosvmtest";
    };
  };

  security = {
    # sudo for privilege escalation
    sudo = {
      enable = true;
      extraConfig = "Defaults lecture=never\nDefaults passwd_timeout=0\nDefaults insults";
    };
    polkit.enable = true; # polkit for privilege escalation
    tpm2.enable = true; # tpm2 support
  };

  services = {
    openssh.enable = true; # ssh
    dbus.enable = true; # system bus
    smartd.enable = true; # disk health monitoring
    thermald.enable = true; # thermal management
    upower.enable = true; # power management
    fwupd.enable = true; # firmware updates
    fstrim.enable = true; # periodic trim for ssd
  };

  # todo: remove home manager
  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    sharedModules = [
      inputs.base16.homeManagerModule
      inputs.ags.homeManagerModules.default
      {
        inherit scheme;
        home.stateVersion = "25.05";
        programs = {
          bash.enable = true;
          info.enable = true;
          hstr.enable = true;
        };
      }
      ({ config, osConfig, lib, ... }:
        {
          config = lib.mkIf osConfig.programs.alacritty.enable {
            programs.alacritty = {
              settings = {
                window.dynamic_padding = false;
                window.padding = { x = 0; y = 0; };
                scrolling.history = 10000;
                scrolling.multiplier = 3;
                selection.save_to_clipboard = true;
                font = {
                  normal = {
                    family = "monospace";
                    style = "Regular";
                  };
                  bold = {
                    family = "monospace";
                    style = "Bold";
                  };
                  italic = {
                    family = "monospace";
                    style = "Italic";
                  };
                  bold_italic = {
                    family = "monospace";
                    style = "Italic";
                  };
                  size = 11;
                };
                colors = with config.scheme.withHashtag; rec {
                  primary = { background = base00; foreground = base07; };
                  cursor = { text = base02; cursor = base07; };
                  normal = {
                    inherit red green yellow blue cyan magenta;
                    black = base00;
                    white = base07;
                  };
                  bright = normal;
                  dim = normal;
                };
              };
            };
          };
        }
      )
      ({ osConfig, lib, pkgs, ... }:
        {
          config = lib.mkIf osConfig.display.niri.enable {
            programs.ags = {
              enable = true;
              configDir = null;
              extraPackages = [ pkgs.residence ];
            };
            systemd.user.services.residence = {
              Unit = {
                ConditionEnvironment = [ "NIRI_SOCKET" ];
                PartOf = [ "graphical-session.target" ];
                After = [ "graphical-session.target" ];
                Wants = [ "graphical-session.target" ];
              };
              Install = {
                WantedBy = [ "graphical-session.target" ];
              };
              Service = {
                Type = "simple";
                ExecStart = lib.getExe pkgs.residence;
                Restart = "on-failure";
                RestartSec = 3;
              };
            };
          };
        }
      )
    ];
  };
}
