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
        };
      lazy-desktop = prev.callPackage ./pkgs/lazy-desktop.nix { };
      youtube = prev.callPackage ./pkgs/youtube.nix { };
    };
  };
  default = final: prev: {
    background = final.callPackage ./pkgs/background.nix { };
    ensure-tailscale-is-connected = final.callPackage ./pkgs/ensure-tailscale-is-connected.nix { };
    ensure-user-is-root = final.callPackage ./pkgs/ensure-user-is-root.nix { };
    ensure-user-is-not-root = final.callPackage ./pkgs/ensure-user-is-not-root.nix { };
    ensure-workspace-is-clean = final.callPackage ./pkgs/ensure-workspace-is-clean.nix { };
    extract-theme = final.callPackage ./pkgs/extract-theme.nix { };
    frigate-desktop = final.callPackage ./pkgs/frigate-desktop.nix { };
    residence-installer = (outputs.lib.nixosSystem {
      hostname = "residence-installer";
      platform = final.system;
      extraModules = [
        ({ pkgs, lib, modulesPath, config, ... }:
          let
            network-status = pkgs.writeShellScriptBin "network-status" ''
              export PATH=${with pkgs; lib.makeBinPath [ iproute2 coreutils gnugrep nettools gum ]}
              set -efu -o pipefail
              msgs=()
              if [[ -e /var/shared/qrcode.utf8 ]]; then
                qrcode=$(gum style --border-foreground 240 --border normal "$(< /var/shared/qrcode.utf8)")
                msgs+=("$qrcode")
              fi
              network_status="Root password: $(cat /var/shared/root-password)
              Local network addresses:
              $(ip -brief -color addr | grep -v 127.0.0.1)
              $([[ -e /var/shared/onion-hostname ]] && echo "Onion address: $(cat /var/shared/onion-hostname)" || echo "Onion address: Waiting for tor network to be ready...")
              Multicast DNS: $(hostname).local"
              network_status=$(gum style --border-foreground 240 --border normal "$network_status")
              msgs+=("$network_status")
              msgs+=("Press 'Ctrl-C' for console access")
              gum join --vertical "''${msgs[@]}"
            '';
          in
          {
            imports = [
              (modulesPath + "/installer/cd-dvd/installation-cd-base.nix")
            ];
            roles = [ "installer" ];
            boot = {
              supportedFilesystems.bcachefs = lib.mkDefault true;
              loader.grub = {
                efiSupport = true;
                efiInstallAsRemovable = true;
              };
            };
            isoImage.squashfsCompression = "zstd";
            image.baseName = lib.mkDefault "residence-installer";
            console.earlySetup = true;
            networking = {
              tempAddresses = "disabled";
              wireless = {
                enable = false;
                iwd = {
                  enable = true;
                  settings = {
                    Network = {
                      EnableIPv6 = true;
                      RoutePriorityOffset = 300;
                    };
                    Settings.AutoConnect = true;
                  };
                };
              };
            };
            services = {
              openssh = {
                enable = true;
                settings.PermitRootLogin = "yes";
              };
              getty.autologinUser = lib.mkForce "root";
            };
            programs.bash.interactiveShellInit = ''
              if [[ "$(tty)" =~ /dev/(tty1|hvc0|ttyS0)$ ]]; then
                systemctl restart systemd-vconsole-setup.service
                watch --no-title --color ${network-status}/bin/network-status
              fi
            '';
            systemd = {
              services.log-network-status = {
                wantedBy = [ "multi-user.target" ];
                restartIfChanged = false;
                serviceConfig = {
                  Type = "oneshot";
                  StandardOutput = "journal+console";
                  ExecStart = [
                    "-${pkgs.systemd}/lib/systemd/systemd-networkd-wait-online"
                    "${pkgs.iproute2}/bin/ip -c addr"
                    "${pkgs.iproute2}/bin/ip -c -6 route"
                    "${pkgs.iproute2}/bin/ip -c -4 route"
                    "${pkgs.systemd}/bin/networkctl status"
                  ];
                };
              };
              tmpfiles.rules = [ "d /var/shared 0777 root root - -" ];
            };
            system.activationScripts.root-password = ''
              mkdir -p /var/shared
              ${pkgs.xkcdpass}/bin/xkcdpass --numwords 3 --delimiter - --count 1 > /var/shared/root-password
              echo "root:$(cat /var/shared/root-password)" | chpasswd
            '';
            environment.systemPackages = with pkgs; map lib.lowPrio [
              curl
              gitMinimal
              nixos-install-tools
              jq
              rsync
              disko
              network-status
            ];
          })
      ];
    });
    residence-iso = final.residence-installer.config.system.build.isoImage;
    mkShell = final.callPackage ./pkgs/mk-shell.nix { };
    network-filters-disable = final.callPackage ./pkgs/network-filters-disable.nix { };
    network-filters-enable = final.callPackage ./pkgs/network-filters-enable.nix { };
    neovim = (packagesFrom inputs.neovim-nightly final.system).neovim;
    residence = final.callPackage ./pkgs/residence { inherit (inputs) ags; inherit (final) system; };
    silverbullet-desktop = final.callPackage ./pkgs/silverbullet-desktop.nix { };
    status = final.callPackage ./pkgs/status.nix { };
    theme = final.callPackage ./pkgs/theme.nix { };
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
    vulnix = final.callPackage (packagesFrom inputs.vulnix).vulnix { };
    lib = prev.lib // outputs.lib;
  };
}
