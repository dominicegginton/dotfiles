{ inputs, outputs }:

rec {
  default = final: prev: with outputs.lib; let callPackage = final.callPackage; platform = final.system; in {
    inherit (outputs) lib;
    bootstrap-nixos-host = callPackage ./pkgs/bootstrap-nixos-host.nix { };
    bootstrap-nixos-installer = callPackage ./pkgs/bootstrap-nixos-installer.nix { };
    ensure-user-is-root = callPackage ./pkgs/ensure-user-is-root.nix { };
    ensure-user-is-not-root = callPackage ./pkgs/ensure-user-is-not-root.nix { };
    ensure-workspace-is-clean = callPackage ./pkgs/ensure-workspace-is-clean.nix { };
    gpg-import-keys = callPackage ./pkgs/gpg-import-keys.nix { };
    host-status = callPackage ./pkgs/host-status.nix { };
    mkShell = import ./pkgs/mk-shell.nix { inherit (prev) mkShell; inherit (final) set-prompt-shell-hook; };
    network-filters-disable = callPackage ./pkgs/network-filters-disable.nix { };
    network-filters-enable = callPackage ./pkgs/network-filters-enable.nix { };
    nixos-anywhere = (packagesFrom inputs.nixos-anywhere platform).nixos-anywhere;
    neovim = (packagesFrom inputs.neovim-nightly platform).neovim;
    set-prompt-shell-hook = callPackage ./pkgs/set-prompt-shell-hook.nix { };
    set-theme = callPackage ./pkgs/set-theme.nix { };
    source-nodejs-packages-shell-hook = callPackage ./pkgs/source-nodejs-packages-shell-hook.nix { };
    todo = (packagesFrom inputs.todo platform).default;
    twm = (packagesFrom inputs.twm platform).default;
    twx = callPackage ./pkgs/twx.nix { };
    vscode-with-extensions = import ./pkgs/vscode-with-extensions.nix { inherit (prev) vscode-with-extensions; inherit (final) vscode-extensions; };
    vulnix = callPackage (packagesFrom inputs.vulnix).vulnix { };
  };

  unstable = final: _: {
    unstable = import inputs.nixpkgs-unstable final // {
      inherit (final) system hostPlatform config;
      overlays = [ default ];
    };
  };
}
