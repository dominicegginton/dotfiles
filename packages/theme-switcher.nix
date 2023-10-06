with import <nixpkgs> {};

let
  theme-switcher = pkgs.writeShellApplication {
    name = "theme-switcher";
    text = ''
      echo "Hello, world!"
    '';
  };
in

stdenv.mkDerivation rec {
  name = "theme-swtcher";

  buildInputs = [ theme-switcher ];
}
