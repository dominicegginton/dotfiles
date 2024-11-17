{ inputs, config, lib, pkgs, stateVersion, ... }:

with lib;

let
  secrets = {
    foo = builtins.readFile (s "foo");
  };

  manifest = pkgs.writeTextFile {
    name = "secrets.json";
    text = builtins.toJSON secrets;
  };

  s = name: pkgs.stdenv.mkDerivation rec {
    inherit name;
    phases = "buildPhase";
    builder = ./secret.sh;
    nativeBuildInputs = with pkgs; [ google-cloud-sdk wget bitwarden-cli ];
    PATH = lib.makeBinPath nativeBuildInputs;
    __noChroot = true;
  };
in

{
  config = {
    system.activationScripts.users.deps = [ "secrets" ];
    system.activationScripts.secrets = {
      supportsDryActivation = true;
      text = ''
        echo "Activating secrets"
      '';
    };
    system.build.manifest = manifest;
    system.activationScripts.test = {
      supportsDryActivation = true;
      text = ''
        echo "Running tests"
        echo "${secrets.foo}"
      '';
      deps = [ "secrets" "users" ];
    };
  };
}
