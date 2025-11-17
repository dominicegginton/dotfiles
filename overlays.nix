{ inputs, outputs }:

with outputs.lib;

rec {
  # default overlay
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
    aide = prev.aide.overrideAttrs (old: {
      configureFlags = (old.configureFlags or [ ]) ++ [ "--sysconfdir=/etc/aide" ];
    });
    background = final.callPackage ./pkgs/background.nix { };
    ensure-tailscale-is-connected = final.callPackage ./pkgs/ensure-tailscale-is-connected.nix { };
    ensure-user-is-root = final.callPackage ./pkgs/ensure-user-is-root.nix { };
    ensure-user-is-not-root = final.callPackage ./pkgs/ensure-user-is-not-root.nix { };
    ensure-workspace-is-clean = final.callPackage ./pkgs/ensure-workspace-is-clean.nix { };
    extract-theme = final.callPackage ./pkgs/extract-theme.nix { };
    frigate-desktop = final.callPackage ./pkgs/frigate-desktop.nix { };
    lazy-desktop = prev.callPackage ./pkgs/lazy-desktop.nix { };
    residence-installer = (outputs.lib.nixosSystem {
      hostname = "residence-installer";
      platform = final.system;
      extraModules = [
        (modulesPath + "/installer/cd-dvd/installation-cd-base.nix")
        ({ pkgs, lib, modulesPath, config, ... }:
          let
            flakeOutPaths =
              let
                collector =
                  parent:
                  map
                    (
                      child:
                      [ child.outPath ] ++ (if child ? inputs && child.inputs != { } then (collector child) else [ ])
                    )
                    (lib.attrValues parent.inputs);
              in
              lib.unique (lib.flatten (collector self));

            dependencies = [
              self.nixosConfigurations.latitude-7390.config.system.build.toplevel
              self.nixosConfigurations.latitude-7390.config.system.build.diskoScript
              self.nixosConfigurations.latitude-7390.config.system.build.diskoScript.drvPath
              self.nixosConfigurations.latitude-7390.pkgs.stdenv.drvPath
              self.nixosConfigurations.latitude-7390.pkgs.perlPackages.ConfigIniFiles
              self.nixosConfigurations.latitude-7390.pkgs.perlPackages.FileSlurp
              (self.nixosConfigurations.latitude-7390.pkgs.closureInfo { rootPaths = [ ]; }).drvPath
            ] ++ flakeOutPaths;

            closureInfo = pkgs.closureInfo { rootPaths = dependencies; };
          in

          {
            roles = [ "installer" ];
            image.baseName = lib.mkDefault "residence-installer";
            console.earlySetup = true;
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
            environment.systemPackages = with pkgs; [
              (writeShellScriptBin "install" ''
                set -eux
                DISKS=$(${pkgs.lsblk}/bin/lsblk -dn -o NAME,TYPE | ${pkgs.gnugrep}/bin/grep 'disk')
                DISK_NAMES=$(echo "$DISKS" | ${pkgs.coreutils}/bin/awk '{print $1}')
                DISK=$(${pkgs.gum}/bin/gum choose $DISK_NAMES --header="Select the target disk for NixOS installation:")
                exec ${pkgs.disko}/bin/disko-install --flake "${self}#runtime" --disk main /dev/$DISK --write-efi-boot-entries
              '')
            ];
          })
      ];
    });
    mkShell = final.callPackage ./pkgs/mk-shell.nix { };
    network-filters-disable = final.callPackage ./pkgs/network-filters-disable.nix { };
    network-filters-enable = final.callPackage ./pkgs/network-filters-enable.nix { };
    plymouth-theme = final.callPackage ./pkgs/plymouth-theme.nix { };
    residence = final.callPackage ./pkgs/residence { inherit (inputs) ags; inherit (final) system; };
    silverbullet-desktop = final.callPackage ./pkgs/silverbullet-desktop.nix { };
    theme = final.callPackage ./pkgs/theme.nix { };
    topology = outputs.topology.${final.system}.config.output;
    twx = final.callPackage ./pkgs/twx.nix { };
    youtube = prev.callPackage ./pkgs/youtube.nix { };
    vscode = prev.vscode.overrideAttrs (oldAttrs: {
      nativeBuildInputs = oldAttrs.nativeBuildInputs or [ ] ++ [ final.makeWrapper ];
      postInstall = (oldAttrs.postInstall or "") + ''
        wrapProgram $out/bin/code \
          --prefix PATH : "${final.lib.makeBinPath [ prev.github-cli prev.nodejs prev.nodePackages.typescript prev.python3 prev.pyright ]}" \
          --set NODE_PATH "${final.nodejs}/lib/node_modules";
      '';
    });
    jetbrains = prev.jetbrains // {
      webstorm = prev.jetbrains.webstorm.overrideAttrs (oldAttrs: {
        nativeBuildInputs = oldAttrs.nativeBuildInputs or [ ] ++ [ final.makeWrapper ];
        postInstall = (oldAttrs.postInstall or "") + ''
          wrapProgram $out/bin/webstorm \
            --prefix PATH : "${final.lib.makeBinPath [ prev.github-cli prev.nodejs prev.nodePackages.typescript prev.python3 prev.pyright ]}" \
            --set NODE_PATH "${final.nodejs}/lib/node_modules";
        '';
      });
    };
    fleet = final.callPackage ./pkgs/fleet.nix { };
    lib = prev.lib // outputs.lib;
  };
}
