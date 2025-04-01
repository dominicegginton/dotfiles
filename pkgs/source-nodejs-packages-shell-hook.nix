{ makeSetupHook, writeScript }:

makeSetupHook { name = "source-nodejs-packages-shell-hook"; }
  (writeScript "source-nodejs-packages-shell-hook.sh" ''export PATH=$PATH:./node_modules/.bin'')
