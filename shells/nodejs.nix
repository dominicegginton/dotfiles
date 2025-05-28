{ lib, mkShell, importNpmLock, nodejs, gum }:

let
  NPM_ROOT = builtins.getEnv "NPM_ROOT";
  NPM_FLAGS = builtins.getEnv "NPM_FLAGS";
in

if NPM_ROOT != "" then

  assert builtins.pathExists NPM_ROOT;

  mkShell {
    name = "ad-hoc nodejs";
    npmDeps = importNpmLock.buildNodeModules {
      inherit nodejs;
      npmRoot = /${NPM_ROOT};
      derivationArgs = {
        npmFlags = lib.splitString " " NPM_FLAGS;
      };
    };
    packages = [ importNpmLock.hooks.linkNodeModulesHook nodejs ];
    meta.maintainers = [ lib.maintainers.dominicegginton ];
  }

else

  mkShell {
    name = "ad-doc nodejs";
    packages = [ nodejs gum ];
    shellHook = ''
      gum log --level warn "NPM_ROOT not set - node_modules will not be linked.";
    '';
    meta.maintainers = [ lib.maintainers.dominicegginton ];
  }
