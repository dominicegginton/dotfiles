{
  self,
  config,
  lib,
  pkgs,
  ...
}:

let
  selfRef = value: { "self" = value; };
in

{
  nix = {
    # Pin the Nix package version for reproducibility
    package = lib.mkForce pkgs.nix;

    # Enable automatic garbage collection (GC)
    gc = {
      automatic = lib.mkForce true; # Always enable GC
      dates = lib.mkForce "weekly"; # Run GC weekly
      options = lib.mkForce "--delete-older-than 7d"; # Remove store paths older than 7 days
    };

    # Enable automatic store optimisation
    optimise.automatic = lib.mkForce true;

    # Disable legacy channel updates (flakes only)
    channel.enable = lib.mkForce false;

    # Nix registry and nixPath for flake-based workflows
    registry = lib.mapAttrs (_: value: { flake = value; }) (self.inputs // selfRef self);
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    # Nix daemon and CLI settings
    settings = {
      # Enable experimental features for modern Nix workflows
      experimental-features = [
        "flakes" # Flake support
        "nix-command" # Nix-command support
        "auto-allocate-uids" # Automatically allocate UIDs
        "cgroups" # Leverage cgroups for resource management
        "fetch-closure" # Enable fetch-closure support
        "parse-toml-timestamps" # Enable parse-toml-timestamps support
        "recursive-nix" # Enable recursive-nix support
        "pipe-operators" # Enable pipe-operators support
      ];

      # Minimum free space for builds (30GB)
      min-free = builtins.toString (30 * 1024 * 1024 * 1024); # 30 GB
      min-free-check-interval = lib.mkForce 1; # Check every 1s

      # Disable global registry (flake registry only)
      flake-registry = lib.mkDefault "";

      # Performance optimizations (uncomment to keep outputs/derivations)
      # keep-outputs = true; # keep build outputs
      # keep-derivations = true; # keep derivations for faster rebuilds

      # Performance and reliability settings
      eval-cache = lib.mkForce true; # Enable evaluation cache
      narinfo-cache-positive-ttl = lib.mkForce 3600; # Cache narinfos for 1h
      narinfo-cache-negative-ttl = lib.mkForce 60; # Retry missing narinfos after 1m
      fsync-metadata = lib.mkForce false; # Faster on SSDs
      connect-timeout = lib.mkForce 10; # 10s connection timeout
      max-substitution-jobs = lib.mkForce 128; # Parallel substitutions
      http-connections = lib.mkForce 128; # Parallel HTTP connections
      cores = lib.mkForce 0; # Use all CPU cores
      max-jobs = lib.mkForce "auto"; # Use all CPU cores
      keep-build-log = lib.mkForce false; # Don't keep build logs
      compress-build-log = lib.mkForce true; # Compress build logs
      require-sigs = lib.mkForce true; # Require signatures for substitutes
      allowed-users = lib.mkForce [
        "root"
        "@wheel"
      ]; # Only allow root and wheel
      trusted-users = lib.mkForce [
        "root"
        "@wheel"
      ]; # Only trust root and wheel
    };
  };

  # Apply nixpkgs overlays for system packages
  nixpkgs.overlays = lib.mkDefault [ self.outputs.overlays.default ];
}
