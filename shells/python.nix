{ lib, pkgs, mkShell }:

mkShell {
  nativeBuildInputs = with pkgs; [
    (lib.development-promt "temp python shell")
    (python3.withPackages (pythonPkgs: with pythonPkgs; [ ]))
    pyright
  ];
}
