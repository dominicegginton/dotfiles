{ inputs, outputs }:

with outputs.lib;

rec {
  unstable = _: prev: {
    unstable = import inputs.nixpkgs-unstable
      { inherit (prev) system hostPlatform config; overlays = [ default ]; }
    //
    { lib = prev.lib // outputs.lib; };
  };
  bleeding = _: prev: {
    bleeding = import inputs.nixpkgs-bleeding
      { inherit (prev) system hostPlatform config; overlays = [ default ]; }
    //
    {
      lib = prev.lib // outputs.lib;
      ms-edit = prev.callPackage
        ({ rustPlatform }:
          rustPlatform.buildRustPackage rec {
            pname = "ms-edit";
            version = "v1.1.0";
            src = prev.fetchFromGitHub {
              owner = "microsoft";
              repo = "edit";
              tag = version;
              hash = "sha256-ubdZynQVwCYhZA/z4P/v6aX5rRG9BCcWKih/PzuPSeE=";
            };
            cargoHash = "sha256-qT4u8LuKX/QbZojNDoK43cRnxXwMjvEwybeuZIK6DQQ=";
          })
        { };
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
  };
  default = final: prev: {
    ensure-tailscale-is-connected = final.callPackage ./pkgs/ensure-tailscale-is-connected.nix { };
    ensure-user-is-root = final.callPackage ./pkgs/ensure-user-is-root.nix { };
    ensure-user-is-not-root = final.callPackage ./pkgs/ensure-user-is-not-root.nix { };
    ensure-workspace-is-clean = final.callPackage ./pkgs/ensure-workspace-is-clean.nix { };
    flameshot = prev.flameshot.overrideAttrs (oldAttrs: {
      cmakeFlags = [
        "-DUSE_WAYLAND_CLIPBOARD=1"
        "-DUSE_WAYLAND_GRIM=1"
      ];
      buildInputs = oldAttrs.buildInputs ++ [ final.libsForQt5.kguiaddons ];
      postInstall = (oldAttrs.postInstall or "") + ''
        wrapProgram $out/bin/flameshot \
          --prefix PATH : "${final.grim}/bin";
      '';
    });
    jetbrains = let vmopts = "-Dawt.toolkit.name=WLToolkit"; in prev.jetbrains // {
      datagrip = prev.jetbrains.datagrip.override { inherit vmopts; };
      webstorm = (prev.jetbrains.webstorm.override { inherit vmopts; }).overrideAttrs (oldAttrs: {
        postInstall = (oldAttrs.postInstall or "") + ''
          wrapProgram $out/bin/webstorm \
            --prefix PATH : "${final.lib.makeBinPath [ prev.nodejs prev.nodePackages.typescript prev.python3 prev.pyright ]}" \
            --set NODE_PATH "${final.nodejs}/lib/node_modules";
        '';
      });
    };
    mkShell = final.callPackage ./pkgs/mk-shell.nix { };
    network-filters-disable = final.callPackage ./pkgs/network-filters-disable.nix { };
    network-filters-enable = final.callPackage ./pkgs/network-filters-enable.nix { };
    neovim = (packagesFrom inputs.neovim-nightly final.system).neovim;
    residence = final.callPackage ./pkgs/residence { inherit (inputs) ags; inherit (final) system; };
    status = final.callPackage ./pkgs/status.nix { };
    todo = (packagesFrom inputs.todo final.system).default;
    topology = outputs.topology.${final.system}.config.output;
    twm = (packagesFrom inputs.twm final.system).default;
    twx = final.callPackage ./pkgs/twx.nix { };
    vscode = prev.vscode.overrideAttrs (oldAttrs: {
      postInstall = (oldAttrs.postInstall or "") + ''
        wrapProgram $out/bin/code \
          --prefix PATH : "${final.lib.makeBinPath [ prev.nodejs prev.nodePackages.typescript prev.python3 prev.pyright ]}" \
          --set NODE_PATH "${final.nodejs}/lib/node_modules";
      '';
    });
    vscode-with-extensions =
      let
        extensions = with prev.vscode-extensions; [
          vscodevim.vim
          github.github-vscode-theme
          github.vscode-pull-request-github
          github.vscode-github-actions
          github.copilot
          ms-azuretools.vscode-docker
          bbenoist.nix
          sumneko.lua
          ms-python.python
          tekumara.typos-vscode
        ];
      in
      (prev.vscode-with-extensions.override { vscodeExtensions = extensions; }) //
      { override = args: prev.vscode-with-extensions.override (args // { vscodeExtensions = extensions ++ (args.vscodeExtensions or [ ]); }); };
    vulnix = final.callPackage (packagesFrom inputs.vulnix).vulnix { };
    lib = prev.lib // outputs.lib;

  };
}
