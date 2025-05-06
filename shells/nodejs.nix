{ lib, mkShell, nodejs, importNpmLock }:

let
  NPM_ROOT = builtins.getEnv "NPM_ROOT";
  NPM_FLAGS = builtins.getEnv "NPM_FLAGS";
in

assert NPM_ROOT != null;
assert NPM_ROOT != "";
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
