{ inputs
, outputs
, config
, lib
, pkgs
, ...
}:
with lib; let
  inherit (pkgs.stdenv) isLinux isDarwin;

  cfg = config.modules.system;
in
{
  options.modules.system = {
    stateVersion = mkOption {
      default = "21.11";
      description = "The state version to use for the system";
    };

    nixpkgs.hostPlatform = mkOption {
      type = types.str;
      default = "x86_64-linux";
      description = "The host platform to use for the system";
    };

    nixpkgs.allowUnfree = mkOption {
      type = types.bool;
      default = false;
      description = "Allow unfree packages to be installed";
    };

    nixpkgs.allowUnfreePredicate = mkOption {
      description = "Allow unfree packages to be installed based on a predicate";
    };

    nixpkgs.permittedInsecurePackages = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Permitted insecure packages to be installed";
    };
  };

  config = {
    nix = {
      package = pkgs.nix;
      gc.automatic = true;
      optimise.automatic = true;
      registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
      nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        keep-outputs = true;
        keep-derivations = true;
        warn-dirty = false;
        # Set auto optimise store to false on darwin
        # to avoid the issue with the store being locked
        # and causing nix to hang when trying to build
        # a derivation. This is a temporary fix until
        # the issue is resolved in nix.
        # SEE: https://github.com/NixOS/nix/issues/7273
        auto-optimise-store =
          if isDarwin
          then false
          else true;
      };
    };

    nixpkgs = {
      hostPlatform = cfg.nixpkgs.hostPlatform;
      config.allowUnfree = cfg.nixpkgs.allowUnfree;
      config.joypixels.acceptLicense = cfg.nixpkgs.allowUnfree;
      config.allowUnfreePredicate = cfg.nixpkgs.allowUnfreePredicate;
      config.permittedInsecurePackages = cfg.nixpkgs.permittedInsecurePackages;
      overlays = [
        outputs.overlays.additions
        outputs.overlays.modifications
        outputs.overlays.unstable-packages
        inputs.neovim-nightly-overlay.overlay
        inputs.todo.overlays.default
      ];
    };

    environment = {
      variables.EDITOR = "vim";
      variables.SYSTEMD_EDITOR = "vim";
      variables.VISUAL = "vim";

      systemPackages = with pkgs;
        [
          gitMinimal # git
          vim # vim
          home-manager # home-manager
          killall # killall processes utility
          unzip # unzip utility
          wget # http client
          htop-vim # system monitor
          btop # better system monitor
          rebuild-host
          rebuild-home
          rebuild-configuration
          upgrade-configuration
          cleanup-trash
          shutdown-host
          reboot-host
          suspend-host
          hibernate-host
        ]
        ++ optionals isLinux [
          usbutils # usb utilities
          nvme-cli # nvme command line interface
          smartmontools # control and monitor stroage systems
        ];
    };

    system.activationScripts.diff = {
      supportsDryActivation = true;
      text = ''
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
      '';
    };
  };
}
