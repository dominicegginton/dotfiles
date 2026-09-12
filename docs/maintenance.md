# Store Maintenance, Garbage Collection & System Diffs

This guide covers operational commands for inspecting system changes, finding dangling Nix store links, and performing Nix store garbage collection.

## 1. Comparing System Generations (`nvd`)

To inspect package additions, updates, or removals between current and new system generations:

```bash
# Compare current booted system against a newly built system profile
nvd diff /run/current-system ./result
```

## 2. Cleaning Dangling Nix Store Symlinks

Use the custom `nix-gc-dangling-links` utility (`pkgs/nix-gc-dangling-links.nix`) to interactively scan `$HOME` for broken symlinks pointing to deleted Nix store paths:

```bash
# Launch interactive TUI scanner for dangling Nix store links
nix-gc-dangling-links
```

## 3. Nix Garbage Collection & Store Optimization

To free disk space by removing unused store paths and generations:

```bash
# Delete system generations older than 14 days
run0 nix-env --delete-generations +14d --profile /nix/var/nix/profiles/system

# Collect garbage and delete unreferenced store paths
run0 nix-store --gc

# Deduplicate identical files across the Nix store
run0 nix-store --optimise
```

## 4. Handling Proprietary / EULA Prefetch Packages (DisplayLink)

Certain proprietary packages (such as `displaylink`) are subject to strict End User License Agreements (EULAs) that prevent NixOS from redistributing the binary output on public substituter caches.

When building a system with `hardware.displaylink.enable = true`, `nixos-rebuild` will fail if the zip payload is not already in the Nix store.

### Prefetching the DisplayLink Binary

If `nixos-rebuild` fails with `Cannot build ... displaylink-*.zip.drv`:

```bash
# Prefetch the DisplayLink driver archive into the local Nix store
nix-prefetch-url --name displaylink-620.zip https://www.synaptics.com/sites/default/files/exe_files/2025-09/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu6.2-EXE.zip
```

Once prefetched, rerun `sudo nixos-rebuild switch --flake .` to complete system activation.

> **Note**: If DisplayLink USB graphics adapters/docks are not used (e.g. using native USB-C DisplayPort Alt Mode), `hardware.displaylink.enable = false` can be configured in the host config to avoid manual prefetching.

