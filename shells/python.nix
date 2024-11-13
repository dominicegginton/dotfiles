{ pkgs, mkShell }:

mkShell {
  nativeBuildInputs = with pkgs; [
    (python3.withPackages (pythonPkgs: with pythonPkgs; [ ]))
    pyright
  ];
}
