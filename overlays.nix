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
          system-manager = karrenScript ''
            selection=$(${prev.uutils-coreutils-noprefix}/bin/printf "suspend\nreboot\nexit\nshutdown" | ${prev.lib.getExe prev.fzf} --no-sort --prompt "> ")
            if [ -z "$selection" ]; then
              exit 1;
            fi
            if [ "$selection" = "shutdown" ]; then
              ${prev.lib.getExe prev.gum} confirm "Shutdown?" && ${prev.systemd}/bin/systemctl poweroff
            elif [ "$selection" = "reboot" ]; then
              ${prev.lib.getExe prev.gum} confirm "Reboot?" && ${prev.systemd}/bin/systemctl reboot
            elif [ "$selection" = "exit" ]; then
              ${prev.lib.getExe prev.gum} confirm "Exit Niri?" && ${prev.niri}/bin/niri msg action quit 
            elif [ "$selection" = "suspend" ]; then
              ${prev.lib.getExe prev.gum} confirm "Suspend?" && ${prev.systemd}/bin/systemctl suspend
            fi
            ${prev.uutils-coreutils-noprefix}/bin/sleep 0.1
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
          lazy-desktop = prev.callPackage ./pkgs/lazy-desktop.nix { };
        };
      youtube = prev.callPackage ./pkgs/youtube.nix { };
    };
  };
  default = final: prev: {
    ensure-tailscale-is-connected = final.callPackage ./pkgs/ensure-tailscale-is-connected.nix { };
    ensure-user-is-root = final.callPackage ./pkgs/ensure-user-is-root.nix { };
    ensure-user-is-not-root = final.callPackage ./pkgs/ensure-user-is-not-root.nix { };
    ensure-workspace-is-clean = final.callPackage ./pkgs/ensure-workspace-is-clean.nix { };
    extract-theme = final.callPackage ./pkgs/extract-theme.nix { };
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
    lib = prev.lib // outputs.lib;
  };
}
