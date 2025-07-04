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
      ## requires vm options to be set
      ## to run on wayland
      jetbrains = prev.jetbrains // {
        fleet = prev.callPackage inputs.jetbrains-fleet { };
      };
      ## fails to build with rustc(1.86)
      ## requires rustc(1.87) or later
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
      ## incomplete implementation
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
      karren = {
        system-manager = prev.writeShellScriptBin "karren-system-manager" ''
          ${prev.lib.getExe prev.alacritty} --title "karren" --class "karren" --command \
            ${prev.lib.getExe (prev.writeShellScriptBin "karren-system-manager-runtime" ''
              selection=$(printf "lock\nshutdown\nreboot\nsuspend\n" | ${prev.lib.getExe prev.fzf} --prompt "Select action: " --no-sort)
              if [ "$selection" = "shutdown" ]; then
                ${prev.lib.getExe prev.gum} confirm "Shutdown?" || exit 1
                execCommand="${prev.systemd}/bin/systemctl poweroff"
              elif [ "$selection" = "reboot" ]; then
                ${prev.lib.getExe prev.gum} confirm "Reboot?" || exit 1
                execCommand="${prev.systemd}/bin/systemctl reboot"
              elif [ "$selection" = "suspend" ]; then
                ${prev.lib.getExe prev.gum} confirm "Suspend?" || exit 1
                execCommand="${prev.systemd}/bin/systemctl suspend"
              elif [ "$selection" = "lock" ]; then
                execCommand="${prev.lib.getExe prev.swaylock-effects} -S --effect-blur 10x10"
              else
                exit 1
              fi
              ${prev.uutils-coreutils-noprefix}/bin/nohup ${prev.bash}/bin/sh -c "$execCommand || ${prev.libnotify}bin/notify-send --urgency=critical 'Karren System Manager' 'Failed to run $selection'" > /dev/null 2>&1 &
              ${prev.uutils-coreutils-noprefix}/bin/sleep 0.1
            '')};
        '';
        tv-guide = prev.writeShellScriptBin "karren-tv-guide" ''
          ${prev.lib.getExe prev.alacritty} --title "karren" --class "karren" --command \
            ${prev.lib.getExe (prev.writeShellScriptBin "karren-tv-guide-runtime" ''
              selection=$(printf "youtube\n" | ${prev.lib.getExe prev.fzf} --prompt "Select TV Guide: " --no-sort)
              if [ "$selection" = "youtube" ]; then
                execCommand="${prev.lib.getExe prev.firefox} --kiosk https://www.youtube.com"
              else
                exit 1
              fi
              ${prev.uutils-coreutils-noprefix}/bin/nohup ${prev.bash}/bin/sh -c "$execCommand || ${prev.libnotify}bin/notify-send --urgency=critical 'Karren TV Guide' 'Failed to run $selection'" > /dev/null 2>&1 &
              ${prev.uutils-coreutils-noprefix}/bin/sleep 10
            '')};
        '';
        clipboard-history = prev.writeShellScriptBin "karren-clipboard-history" ''${prev.lib.getExe prev.alacritty} --title "karren" --class "karren" --command ${prev.lib.getExe (prev.writeShellScriptBin "karren-clipboard-history-runtime" ''${prev.lib.getExe prev.cliphist} list | ${prev.lib.getExe prev.fzf} --no-sort --prompt "Select clipboard entry: " | ${prev.lib.getExe prev.cliphist} decode | ${prev.wl-clipboard}/bin/wl-copy'')};'';
        launcher = prev.writeShellScriptBin "karren-launcher" ''
          ${prev.lib.getExe prev.alacritty} --title "karren" --class "karren" --command \
            ${prev.lib.getExe (prev.writeShellScriptBin "karren-lunacher-runtime" ''
              export PATH=${prev.lib.makeBinPath [ prev.gum prev.fzf prev.uutils-findutils prev.uutils-coreutils-noprefix prev.libnotify ]}:$PATH; 
              desktopFiles=$(find /etc/profiles/per-user/*/share/applications ~/.local/share/applications -name "*.desktop" -print)
              selection=$(echo "$desktopFiles" | fzf --prompt "Run: " --preview "cat {}")
              if [ -z "$selection" ]; then
                exit 1;
              fi
              execCommand=$(cat "$selection" | grep '^Exec=' | cut -d '=' -f 2- | sed 's/ %.*//')
              if [ $(cat "$selection" | grep -c '^Terminal=true') -gt 0 ]; then 
                execCommand="alacritty --command $execCommand";
              fi
              nohup sh -c "$execCommand || notify-send --urgency=critical 'Karren Launcher' 'Failed to run $selection'" > /dev/null 2>&1 &
              sleep 0.1
            '')};
        '';
        lazy-launcher = prev.writeShellScriptBin "karren-lazy-launcher" ''
          ${prev.lib.getExe prev.alacritty} --title "karren" --class "karren" --command \
            ${prev.lib.getExe (prev.writeShellScriptBin "karren-lazy-runtime" ''
              export PATH=${prev.lib.makeBinPath [ prev.gum prev.fzf prev.uutils-findutils prev.uutils-coreutils-noprefix prev.libnotify ]}:$PATH; 
              desktopFiles=$(find /run/current-system/sw/share/applications -name '*.desktop' -print)
              selection=$(echo "$desktopFiles" | fzf --prompt "Run: " --preview "cat {}")
              if [ -z "$selection" ]; then
                exit 1;
              fi
              execCommand=$(cat "$selection" | grep '^Exec=' | cut -d '=' -f 2- | sed 's/ %.*//')
              if [ $(cat "$selection" | grep -c '^Terminal=true') -gt 0 ]; then 
                execCommand="alacritty --command $execCommand";
              fi
              nohup sh -c "$execCommand || notify-send --urgency=critical 'Karren Lazy' 'Failed to run $selection'" > /dev/null 2>&1 &
              notify-send "Karren Lazy" "$execCommand\n\nThis may take a while to start if the package is not already in the nix store."
            '')};
        '';
        lazy-desktop = prev.callPackage
          ({ lib
           , stdenv
           , runCommand
           , nix-index
           , desktop-file-utils
           }:
            let
              nix-index-database = builtins.fetchurl {
                url = "https://github.com/nix-community/nix-index-database/releases/download/2025-06-29-034928/index-x86_64-linux";
                sha256 = "ca077887a89c8dc194361f282b24dc11acde744b2aab96bde640ea915f7f3baf";
              };
            in
            stdenv.mkDerivation {
              name = "karren.lazy-desktop";
              buildInputs = [
                nix-index
                desktop-file-utils
              ];
              dontUnpack = true;
              dontBuild = true;
              installPhase = ''
                mkdir -p $out/share/applications
                ln -s ${nix-index-database} files
                nix-locate \
                  --db . \
                  --top-level \
                  --minimal \
                  --regex \
                  '/share/applications/.*\.desktop$' \
                  | while read -r package
                  do
                    cat > $out/share/applications/"$package.desktop" << EOF
                [Desktop Entry]
                Version=1.0
                Name="Lazy: $package"
                Type=Application
                Exec=nix run "nixpkgs#$package"
                EOF
                    desktop-file-validate $out/share/applications/"$package.desktop"
                  done
              '';
              meta = {
                platforms = lib.platforms.linux;
                maintainers = with lib.maintainers; [ dominicegginton ];
                description = ''
                  A package with desktop files for all packages in the nix-index database.
                  When a .desktop is executed it will run the package using `nix run nixpkgs#package`.
                '';
              };
            })
          { };
      };
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
      buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ final.makeWrapper ];
      postInstall = (oldAttrs.postInstall or "") + ''
        wrapProgram $out/bin/flameshot \
          --prefix PATH : "${final.grim}/bin" \
          --set QT_QPA_PLATFORM "wayland";
      '';
    });
    jetbrains =
      let
        vmopts = ''
          -Dawt.toolkit.name=WLToolkit
          -Xmx8G
          -Xms2G
          -XX:NewRatio=1
        '';
      in
      prev.jetbrains // {
        datagrip = prev.jetbrains.datagrip.override { inherit vmopts; };
        webstorm = (prev.jetbrains.webstorm.override { inherit vmopts; }).overrideAttrs (oldAttrs: {
          nativeBuildInputs = oldAttrs.nativeBuildInputs or [ ] ++ [ final.makeWrapper ];
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
      nativeBuildInputs = oldAttrs.nativeBuildInputs or [ ] ++ [ final.makeWrapper ];
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
          (prev.vscode-utils.buildVscodeMarketplaceExtension {
            mktplcRef = {
              name = "vscode-jest";
              publisher = "orta";
              version = "6.4.3";
              hash = "sha256-naSH6AdAlyDSW/k250cUZGYEdKCUi63CjJBlHhkWBPs=";
            };
          })
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
    wlogout = prev.wlogout.overrideAttrs (oldAttrs: {
      nativeBuildInputs = oldAttrs.nativeBuildInputs or [ ] ++ [ final.makeWrapper ];
      postInstall = (oldAttrs.postInstall or "") + ''
        wrapProgram $out/bin/wlogout \
          --prefix PATH : "${final.lib.makeBinPath [ prev.wl-clipboard prev.swaylock ]}" \
          --set WLR_BACKEND "wayland";
      '';
    });
    lib = prev.lib // outputs.lib;
  };
}
