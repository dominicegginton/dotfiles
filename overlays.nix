{ inputs, outputs }:

with outputs.lib;

rec {
  default = final: prev:
    let
      callPackage = final.callPackage;
      platform = final.system;
    in
    {
      ensure-user-is-root = callPackage ./pkgs/ensure-user-is-root.nix { };
      ensure-user-is-not-root = callPackage ./pkgs/ensure-user-is-not-root.nix { };
      ensure-workspace-is-clean = callPackage ./pkgs/ensure-workspace-is-clean.nix { };
      gpg-import-keys = callPackage ./pkgs/gpg-import-keys.nix { };
      status = callPackage ./pkgs/status.nix { };
      mkShell = import ./pkgs/mk-shell.nix { inherit (prev) mkShell; inherit (final) set-prompt-shell-hook; };
      network-filters-disable = callPackage ./pkgs/network-filters-disable.nix { };
      network-filters-enable = callPackage ./pkgs/network-filters-enable.nix { };
      nixos-anywhere = (packagesFrom inputs.nixos-anywhere platform).nixos-anywhere;
      nearch = callPackage ./pkgs/nearch.nix { };
      neovim = (packagesFrom inputs.neovim-nightly platform).neovim;
      nun = callPackage ./pkgs/nun.nix { };
      set-prompt-shell-hook = callPackage ./pkgs/set-prompt-shell-hook.nix { };
      set-theme = callPackage ./pkgs/set-theme.nix { };
      todo = (packagesFrom inputs.todo platform).default;
      twm = (packagesFrom inputs.twm platform).default;
      twx = callPackage ./pkgs/twx.nix { };
      vscode-with-extensions = import ./pkgs/vscode-with-extensions.nix { inherit (prev) vscode-with-extensions; inherit (final) vscode-extensions; };
      vulnix = callPackage (packagesFrom inputs.vulnix).vulnix { };
      lib = prev.lib // outputs.lib;
    };
  unstable = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system hostPlatform config;
      overlays = [ default ];
    };
    lib = prev.lib // outputs.lib;
  };
}
