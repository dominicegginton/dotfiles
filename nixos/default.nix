{ config
, desktop
, hostname
, inputs
, lib
, modulesPath
, outputs
, pkgs
, platform
, stateVersion
, username
, ...
}:

{
  imports = [
    inputs.disko.nixosModules.disko
    (modulesPath + "/installer/scan/not-detected.nix")
    ./${hostname}
    ./_common/console
    ./_common/services/firewall.nix
    ./_common/services/tailescale.nix
    ./_common/services/smartmon.nix
    ./_common/users/root
  ]
  ++ lib.optional (builtins.pathExists ./_common/users/${username}) (import ./_common/users/${username})
  ++ lib.optional (desktop != null) ./_common/desktop;

  i18n = {
    defaultLocale = "en_GB.utf8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_GB.utf8";
      LC_IDENTIFICATION = "en_GB.utf8";
      LC_MEASUREMENT = "en_GB.utf8";
      LC_MONETARY = "en_GB.utf8";
      LC_NAME = "en_GB.utf8";
      LC_NUMERIC = "en_GB.utf8";
      LC_PAPER = "en_GB.utf8";
      LC_TELEPHONE = "en_GB.utf8";
      LC_TIME = "en_GB.utf8";
    };
  };
  services.xserver.layout = "gb";
  time.timeZone = "Europe/London";

  documentation.enable = true;
  documentation.nixos.enable = false;
  documentation.man.enable = true;
  documentation.info.enable = false;
  documentation.doc.enable = false;

  environment = {
    defaultPackages = with pkgs; lib.mkForce [
      gitMinimal
      home-manager
      vim
      rsync
    ];
    systemPackages = with pkgs; [
      unzip
      usbutils
      wget
      wpa_supplicant_gui
      rebuild-host
      rebuild-home
    ];
    variables = {
      EDITOR = "vim";
      SYSTEMD_EDITOR = "vim";
      VISUAL = "vim";
    };
  };

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "SourceCodePro" "UbuntuMono" ]; })
      fira
      fira-go
      joypixels
      liberation_ttf
      noto-fonts-emoji
      source-serif
      ubuntu_font_family
      work-sans
      jetbrains-mono
    ];

    enableDefaultFonts = false;

    fontconfig = {
      antialias = true;
      defaultFonts = {
        serif = [ "Source Serif" ];
        sansSerif = [ "Work Sans" "Fira Sans" "FiraGO" ];
        monospace = [ "FiraCode Nerd Font Mono" "SauceCodePro Nerd Font Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };
      enable = true;
      hinting = {
        autohint = false;
        enable = true;
        style = "hintslight";
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "light";
      };
    };
  };

  networking = {
    hostName = hostname;
    useDHCP = lib.mkDefault true;
  };

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      inputs.neovim-nightly-overlay.overlay
      inputs.nixneovimplugins.overlays.default
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
      joypixels.acceptLicense = true;
    };
  };

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 10d";
    };
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    optimise.automatic = true;
    package = pkgs.unstable.nix;
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      keep-outputs = true;
      keep-derivations = true;
      warn-dirty = false;
    };
  };

  security = {
    sudo.execWheelOnly = true;
    polkit.enable = true;
    rtkit.enable = true;
  };

  programs = {
    command-not-found.enable = false;
  };

  systemd.tmpfiles.rules = [
    "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root"
    "d /mnt/snapshot/${username} 0755 ${username} users"
  ];

  system.stateVersion = stateVersion;
}
