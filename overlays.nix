{ inputs, outputs }:

with outputs.lib;

rec {
  unstable = _: prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (prev) system hostPlatform config;
      overlays = [ default ];
    };
    lib = prev.lib // outputs.lib;
  };
  bleeding = _: prev: {
    bleeding = import inputs.nixpkgs-bleeding {
      inherit (prev) system hostPlatform config;
      overlays = [ default ];
    };
    lib = prev.lib // outputs.lib;
  };
  default = final: prev: {
    ensure-tailscale-is-connected = final.callPackage ./pkgs/ensure-tailscale-is-connected.nix { };
    ensure-user-is-root = final.callPackage ./pkgs/ensure-user-is-root.nix { };
    ensure-user-is-not-root = final.callPackage ./pkgs/ensure-user-is-not-root.nix { };
    ensure-workspace-is-clean = final.callPackage ./pkgs/ensure-workspace-is-clean.nix { };
    status = final.callPackage ./pkgs/status.nix { };
    mkShell = final.callPackage ./pkgs/mk-shell.nix { };
    network-filters-disable = final.callPackage ./pkgs/network-filters-disable.nix { };
    network-filters-enable = final.callPackage ./pkgs/network-filters-enable.nix { };
    nearch = final.callPackage ./pkgs/nearch.nix { };
    neovim = (packagesFrom inputs.neovim-nightly final.system).neovim;
    nun = final.callPackage ./pkgs/nun.nix { };
    set-theme = final.callPackage ./pkgs/set-theme.nix { };
    todo = (packagesFrom inputs.todo final.system).default;
    topology = outputs.topology.${final.system}.config.output;
    twm = (packagesFrom inputs.twm final.system).default;
    twx = final.callPackage ./pkgs/twx.nix { };
    vscode-with-extensions = import ./pkgs/vscode-with-extensions.nix { inherit (prev) vscode-with-extensions; inherit (final) vscode-extensions; };
    vulnix = final.callPackage (packagesFrom inputs.vulnix).vulnix { };
    lib = prev.lib // outputs.lib;
    bootstrap = with final; writeShellScriptBin "bootstrap" ''
      export PATH=${lib.makeBinPath [ status ensure-user-is-root ensure-tailscale-is-connected coreutils git busybox nix fzf jq gum bws ]};
      set -efu -o pipefail
      ensure-user-is-root
      ensure-tailscale-is-connected
      status
      gum style --foreground '#ff0000' --bold "CURRENTLY IN DEVELOPMENT"
      gum confirm "Accept warning Are you sure you want to continue?" || {
        gum log --level error "User cancelled the bootstrap process."
        exit 0;
      }
      temp=$(mktemp -d)
      cleanup() {
        gum log --level info "Cleaning up temporary directory $temp."
        rm -rf "$temp" || true
      }
      trap cleanup EXIT
      git clone --depth 1 https://github.com/dominicegginton/dotfiles "$temp/dotfiles" || {
        gum log --level error "Failed to clone dotfiles repository."
        exit 1;
      }
    '';
  };
}
