{pkgs}:
pkgs.stdenv.mkDerivation {
  name = "hello";
  src = builtins.fetchTarball {
    url = "https://ftp.gnu.org/gnu/hello/hello-2.10.tar.gz";
    sha256 = "sha256:1im1gglfm4k10bh4mdaqzmx3lm3kivnsmxrvl6vyvmfqqzljq75l";
  };
}
