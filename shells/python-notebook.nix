{ lib, mkShell, python3, pyright, vscode-extensions, vscode-with-extensions }:

mkShell {
  nativeBuildInputs = [
    (lib.development-promt "temp python notebooks shell")
    (python3.withPackages (pythonPkgs: with pythonPkgs; [
      jupyterlab
      notebook
    ]))
    pyright
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        bbenoist.nix
        vscodevim.vim
        ms-python.python
        ms-pyright.pyright
        ms-toolsai.jupyter
      ];
    })
  ];
}
