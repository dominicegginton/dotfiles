{ lib, pkgs, config, ... }:

let
  flakePkg = uri: (builtins.getFlake uri).packages.${builtins.currentSystem}.default;
in
{
  home.activation.aliasApplications = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
    let
      apps = pkgs.buildEnv {
        name = "home-manager-applications";
        paths = config.home.packages;
        pathsToLink = "/Applications";
      };
      lastAppsFile = "${config.xdg.stateHome}/nix/.apps";
    in
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        last_apps=$(cat "${lastAppsFile}" 2>/dev/null || echo "")
        next_apps=$(readlink -f ${apps}/Applications/* | sort)

        if [ "$last_apps" != "$next_apps" ]; then
          echo "Apps have changed. Updating macOS aliases..."

          apps_path="$HOME/Applications/NixApps"
          $DRY_RUN_CMD mkdir -p "$apps_path"

          $DRY_RUN_CMD ${pkgs.fd}/bin/fd \
            -t l -d 1 . ${apps}/Applications \
            -x $DRY_RUN_CMD "${flakePkg "github:reckenrode/mkAlias"}/bin/mkalias" \
            -L {} "$apps_path/{/}"

          [ -z "$DRY_RUN_CMD" ] && echo "$next_apps" > "${lastAppsFile}"
        fi
      ''
  );
}
