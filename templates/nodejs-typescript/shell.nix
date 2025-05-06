{ mkShell, hello-world }:

mkShell {
  inputsFrom = [ hello-world ];
  npmConfigHook = importNpmLock.npmConfigHook;
  npmDeps = importNpmLock.buildNodeModules {
    inherit nodejs;
    npmRoot = hello-world.src;
  };
  packages = [ importNpmLock.hooks.linkNodeModulesHook ];
}
