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
