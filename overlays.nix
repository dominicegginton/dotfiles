{ inputs, outputs }:

with outputs.lib;

rec {
  default = final: prev: {
    ensure-user-is-root = final.callPackage ./pkgs/ensure-user-is-root.nix { };
    ensure-user-is-not-root = final.callPackage ./pkgs/ensure-user-is-not-root.nix { };
    ensure-workspace-is-clean = final.callPackage ./pkgs/ensure-workspace-is-clean.nix { };
    status = final.callPackage ./pkgs/status.nix { };
    mkShell = import ./pkgs/mk-shell.nix { inherit (prev) mkShell; inherit (final) set-prompt-shell-hook; };
    network-filters-disable = final.callPackage ./pkgs/network-filters-disable.nix { };
    network-filters-enable = final.callPackage ./pkgs/network-filters-enable.nix { };
    nearch = final.callPackage ./pkgs/nearch.nix { };
    neovim = (packagesFrom inputs.neovim-nightly final.system).neovim;
    nun = final.callPackage ./pkgs/nun.nix { };
    set-prompt-shell-hook = final.callPackage ./pkgs/set-prompt-shell-hook.nix { };
    set-theme = final.callPackage ./pkgs/set-theme.nix { };
    todo = (packagesFrom inputs.todo final.system).default;
    twm = (packagesFrom inputs.twm final.system).default;
    twx = final.callPackage ./pkgs/twx.nix { };
    vscode-with-extensions = import ./pkgs/vscode-with-extensions.nix { inherit (prev) vscode-with-extensions; inherit (final) vscode-extensions; };
    vulnix = final.callPackage (packagesFrom inputs.vulnix).vulnix { };
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
