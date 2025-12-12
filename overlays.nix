{ self }:

with self.outputs.lib;

rec {
  default = final: prev: {
    withSbomnix = prev.callPackage ./pkgs/with-sbomnix.nix { };
    karren =
      let
        alacrittyConfig = (prev.formats.toml { }).generate "alacritty-config.toml" {
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

          ${prev.toybox}/bin/nohup sh -c "${prev.lib.getExe prev.alacritty} --title 'karren' --class 'karren' --config-file '${alacrittyConfig}' --command ${prev.lib.getExe (prev.writeShellScriptBin "karren-runtime" runtimeScript)}" > /dev/null 2>&1 &
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
      };
    aide = prev.aide.overrideAttrs (old: {
      configureFlags = (old.configureFlags or [ ]) ++ [ "--sysconfdir=/etc/aide" ];
    });
    background = final.callPackage ./pkgs/background.nix { };
    ensure-tailscale-is-connected = final.callPackage ./pkgs/ensure-tailscale-is-connected.nix { };
    ensure-user-is-root = final.callPackage ./pkgs/ensure-user-is-root.nix { };
    ensure-user-is-not-root = final.callPackage ./pkgs/ensure-user-is-not-root.nix { };
    ensure-workspace-is-clean = final.callPackage ./pkgs/ensure-workspace-is-clean.nix { };
    extract-theme = final.callPackage ./pkgs/extract-theme.nix { };
    lazy-desktop = prev.callPackage ./pkgs/lazy-desktop.nix { };
    mkGnomeBackground = final.callPackage ./pkgs/mk-gnome-background.nix { };
    mkShell = final.callPackage ./pkgs/mk-shell.nix { };
    network-filters-disable = final.callPackage ./pkgs/network-filters-disable.nix { };
    network-filters-enable = final.callPackage ./pkgs/network-filters-enable.nix { };
    nix-github-authentication = final.callPackage ./pkgs/nix-github-authentication.nix { };
    plymouth-theme = final.callPackage ./pkgs/plymouth-theme.nix { };
    residence = final.callPackage ./pkgs/residence { inherit (self.inputs) ags; inherit (final) system; };
    silverbullet-desktop = final.callPackage ./pkgs/silverbullet-desktop.nix { };
    theme = final.callPackage ./pkgs/theme.nix { };
    topology = outputs.topology.${final.system}.config.output;
    twx = final.callPackage ./pkgs/twx.nix { };
    youtube = prev.callPackage ./pkgs/youtube.nix { };
    vscode = prev.vscode.overrideAttrs (oldAttrs: {
      nativeBuildInputs = oldAttrs.nativeBuildInputs or [ ] ++ [ final.makeWrapper ];
      postInstall = (oldAttrs.postInstall or "") + ''
        wrapProgram $out/bin/code \
          --prefix PATH : "${final.lib.makeBinPath [ prev.github-cli prev.nodejs prev.nodePackages.typescript prev.python3 prev.pyright prev.rust-analyzer prev.terraform-lsp prev.eslint_d prev.typos-lsp prev.stylua prev.nixpkgs-fmt]}" \
          --set NODE_PATH "${final.nodejs}/lib/node_modules";
      '';
    });
    jetbrains = prev.jetbrains // {
      webstorm = prev.jetbrains.webstorm.overrideAttrs (oldAttrs: {
        nativeBuildInputs = oldAttrs.nativeBuildInputs or [ ] ++ [ final.makeWrapper ];
        postInstall = (oldAttrs.postInstall or "") + ''
          wrapProgram $out/bin/webstorm \
            --prefix PATH : "${final.lib.makeBinPath [ prev.github-cli prev.nodejs prev.nodePackages.typescript prev.python3 prev.pyright prev.rust-analyzer t]}" \
            --set NODE_PATH "${final.nodejs}/lib/node_modules";
        '';
      });
    };
    fleet = final.callPackage ./pkgs/fleet.nix { };
  };
}
