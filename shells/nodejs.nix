{ lib, mkShell, nodejs, importNpmLock }:

let
  NPM_ROOT = builtins.getEnv "NPM_ROOT";
in

assert NPM_ROOT != null && NPM_ROOT != "";

mkShell {
  name = "ad-hoc nodejs";
  npmDeps = importNpmLock.buildNodeModules { inherit nodejs; npmRoot = /${NPM_ROOT}; };
  packages = [ importNpmLock.hooks.linkNodeModulesHook nodejs ];
  meta.maintainers = [ lib.maintainers.dominicegginton ];
}
