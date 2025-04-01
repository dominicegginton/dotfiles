{ mkShell, python3, pyright }:

mkShell {
  nativeBuildInputs = [
    (python3.withPackages (pythonPkgs: with pythonPkgs; [ ]))
    pyright
  ];
}
