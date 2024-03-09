{pkgs, ...}:
pkgs.mkShell rec {
  nativeBuildInputs = with pkgs; [];
}
