{ makeSetupHook, writeScript }:

makeSetupHook { name = "nodejs-setup-hook"; }
  (writeScript "nodejs-setup-hook.sh" ''export PATH=$PATH:./node_modules/.bin'')
