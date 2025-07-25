{ inputs, outputs }:

with outputs.lib;

rec {
  unstable = _: prev: {
    unstable = import inputs.nixpkgs-unstable
      { inherit (prev) system hostPlatform config; overlays = [ default ]; }
    //
    { lib = prev.lib // outputs.lib; };
  };
  bleeding = final: prev: {
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
      karren =
        let
          alacrittyConiguration = (prev.formats.toml { }).generate "alacritty-config.toml" {
            colors = {
              primary = {
                background = "#6c71c1";
                foreground = "#FDF6E3";
              };
            };
          };
          karrenScript = runtimeScript: prev.writeShellScriptBin "karren" ''
            set -efu -o pipefail
            if [ $(${prev.toybox}/bin/pgrep -c karren) -gt 1 ]; then
              ${prev.libnotify}/bin/notify-send --urgency=critical --app "Karren" "Karren" "Another instance of is already running." "Please close all existing Karren windows before starting a new one."
              exit 1;
            fi

            ${prev.toybox}/bin/nohup sh -c "${prev.lib.getExe prev.alacritty} --title 'karren' --class 'karren' --config-file '${alacrittyConiguration}' --command ${prev.lib.getExe (prev.writeShellScriptBin "karren-runtime" runtimeScript)}" > /dev/null 2>&1 &
          '';
        in
        {
          system-manager =
            let
              lockscreenscript = "${prev.swaylock-effects}/bin/swaylock-effects -FS --effect-blur 10x10";
            in
            karrenScript ''
              selection=$(printf "suspend\nreboot\nshutdown" | ${prev.lib.getExe prev.fzf} --no-sort --prompt "Select action: ")
              if [ -z "$selection" ]; then
                exit 1;
              fi
              if [ "$selection" = "shutdown" ]; then
                ${prev.lib.getExe prev.gum} confirm "Shutdown?" && ${prev.systemd}/bin/systemctl poweroff
              elif [ "$selection" = "reboot" ]; then
                ${prev.lib.getExe prev.gum} confirm "Reboot?" && ${prev.systemd}/bin/systemctl reboot
              elif [ "$selection" = "suspend" ]; then
                ${prev.lib.getExe prev.gum} confirm "Suspend?" && ${prev.systemd}/bin/systemctl suspend && ${lockscreenscript}
              fi
            '';
          theme-switcher = karrenScript ''
            selection=$(printf "light\ndark" | ${prev.lib.getExe prev.fzf} --no-sort --prompt "Select theme: ")
            if [ -z "$selection" ]; then
              exit 1;
            fi
            ${prev.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme "prefer-$selection"
            ${prev.libnotify}/bin/notify-send --app "Karren" "" "Switched to $selection theme."
            sleep 0.1
          '';
          clipboard-history = karrenScript ''
            selection=$(${prev.cliphist}/bin/cliphist list | ${prev.fzf}/bin/fzf --no-sort --prompt "Select clipboard entry: ")
            if [ -z "$selection" ]; then
              exit 1;
            fi
            echo "$selection" | ${prev.cliphist}/bin/cliphist decode | ${prev.wl-clipboard}/bin/wl-copy
            ${prev.libnotify}/bin/notify-send --app "Karren" "" "Copied clipboard entry to clipboard."
            sleep 0.1
          '';
          launcher = karrenScript ''
            export PATH=${prev.lib.makeBinPath [ prev.fzf prev.uutils-findutils prev.uutils-coreutils-noprefix prev.libnotify ]}:$PATH
            desktopFiles=$(find /etc/profiles/per-user/*/share/applications ~/.local/share/applications /run/current-system/sw/share/applications -name "*.desktop" -print)
            selection=$(echo "$desktopFiles" | ${prev.fzf}/bin/fzf --prompt "Run: ")
            if [ -z "$selection" ]; then
              exit 1;
            fi
            if [ $(cat "$selection" | grep -c '^Exec=') -gt 1 ]; then
              execCommand=$(cat "$selection" | grep '^Exec=' | cut -d '=' -f 2- | sed 's/ %.*//' | ${prev.fzf}/bin/fzf -i --prompt "Exec: " --no-sort)
            else
              execCommand=$(cat "$selection" | grep '^Exec=' | cut -d '=' -f 2- | sed 's/ %.*//')
            fi
            if [ -z "$execCommand" ]; then
              exit 1;
            fi
            if [ $(cat "$selection" | grep -c '^Terminal=true') -gt 0 ]; then
              execCommand="alacritty --command $execCommand"
            fi
            if [ -z "$execCommand" ]; then
              exit 1;
            fi
            if echo "$execCommand" | grep -q "nix run"; then
              ${prev.libnotify}/bin/notify-send --app "Karren" "" "$execCommand\n\nThis may take a while to start if the package is not already in the nix store."
              execCommand="$execCommand || { ${prev.libnotify}/bin/notify-send --urgency=critical --app "Karren" "" "Failed to run: $execCommand"; exit 1; } && { ${prev.libnotify}/bin/notify-send --app "Karren" "" "Successfully ran: $execCommand"; exit 0; }"
            fi
            nohup sh -c "$execCommand &" > /dev/null 2>&1
          '';
          hl-desktop = prev.callPackage
            ({ lib, stdenv, desktop-file-utils, chromium }:
              stdenv.mkDerivation {
                name = "karren.hl-desktop";
                buildInputs = [ desktop-file-utils ];
                dontUnpack = true;
                dontBuild = true;
                installPhase =
                  let
                    urls = {
                      sb = "http://sb.ghost-gs60";
                      ha = "https://ha.ghost-gs60";
                      fg = "https://fg.ghost-gs60";
                    };
                  in
                  ''
                    mkdir -p $out/share/applications
                    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: url: ''
                      cat > $out/share/applications/karren-hl-${name}.desktop << EOF
                    [Desktop Entry]
                    Version=1.0
                    Name="Karren HL: ${name}"
                    Type=Application
                    Exec=${lib.getExe chromium} --app=${url}
                    EOF
                      desktop-file-validate $out/share/applications/karren-hl-${name}.desktop
                    '') urls)}
                  '';
                meta = {
                  platforms = lib.platforms.linux;
                  maintainers = with lib.maintainers; [ dominicegginton ];
                  description = ''
                    A package with desktop files for homelab services.
                    When a .desktop is executed it will open the service in chromium application mode.
                  '';
                };
              })
            { };
          tv-desktop = prev.callPackage
            ({ lib, stdenv, desktop-file-utils, chromium }:
              stdenv.mkDerivation {
                name = "karren.tv-desktop";
                buildInputs = [ desktop-file-utils ];
                dontUnpack = true;
                dontBuild = true;
                installPhase =
                  let
                    urls = {
                      youtube = "https://www.youtube.com";
                      netflix = "https://www.netflix.com";
                    };
                  in
                  ''
                    mkdir -p $out/share/applications
                    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: url: ''
                      cat > $out/share/applications/karren-tv-${name}.desktop << EOF
                    [Desktop Entry]
                    Version=1.0
                    Name="Karren TV: ${name}"
                    Type=Application
                    Exec=${lib.getExe chromium} --app=${url}
                    EOF
                      desktop-file-validate $out/share/applications/karren-tv-${name}.desktop
                    '') urls)}
                  '';
                meta = {
                  platforms = lib.platforms.linux;
                  maintainers = with lib.maintainers; [ dominicegginton ];
                  description = ''
                    A package with desktop files for popular TV streaming services.
                    When a .desktop is executed it will open the service in chromium application mode.
                  '';
                };
              })
            { };
          lazy-desktop = prev.callPackage
            ({ lib, stdenv, nix-index, desktop-file-utils }:
              stdenv.mkDerivation {
                name = "karren.lazy-desktop";
                buildInputs = [ nix-index desktop-file-utils ];
                dontUnpack = true;
                dontBuild = true;
                installPhase =
                  let
                    nix-index-database = builtins.fetchurl {
                      url = "https://github.com/nix-community/nix-index-database/releases/download/2025-07-06-034719/index-x86_64-linux";
                      sha256 = "b8f0b5d94d2b43716e4f0e26dbc9f141b238c3f516618b592c2a9435cdacd8a1";
                    };
                  in
                  ''
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
                    Terminal=false
                    Categories=Utility;
                    Comment="Run the package $package using nix run"
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
      local-web-app = prev.callPackage
        ({ stdenv, lib, chromium }: stdenv.mkDerivation rec {
          pname = "local-web-app";
          version = "1.0";
          dontBuild = true;
          dontUnpack = true;
          installPhase = ''
            mkdir -p $out/share/doc/${pname}
            cat > $out/share/doc/${pname}/${pname}.html <<EOF
            <html>
            <head>
            <title>${pname}</title>
            <style>
            * { background: blue; color: white; }
            </style>
            </head>
            <body>
            <h1>${pname}</h1>
            <p>${meta.description}</p>
            </body>
            </html>
            EOF
            mkdir -p $out/bin
            cat > $out/bin/${pname} <<EOF
            #!${stdenv.shell}
            exec ${lib.getExe chromium} --app=file://$out/share/doc/${pname}/${pname}.html
            EOF
            chmod +x $out/bin/${pname}
            mkdir -p $out/share/applications
            cat > $out/share/applications/${pname}.desktop <<EOF
            [Desktop Entry]
            Version=${version}
            Name=${pname}
            Comment=${meta.description}
            Exec=$out/bin/${pname}
            Terminal=false
            Type=Application
            Categories=Utility;
            EOF
          '';
          meta = {
            description = "A simple example package";
            license = with prev.lib.licenses; [ mit ];
            maintainers = with prev.lib.maintainers; [ dominicegginton ];
          };
        })
        { };
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
