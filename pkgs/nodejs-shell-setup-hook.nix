{ makeSetupHook, writeScript }:

makeSetupHook { name = "nodejs-shell-setup-hook"; }
  (writeScript "nodejs-shell-setup-hook.sh" ''export PATH=$PATH:./node_modules/.bin'')
