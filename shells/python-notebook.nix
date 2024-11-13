{ pkgs, mkShell, vscode-extensions, vscode-with-extensions }:

mkShell {
  nativeBuildInputs = with pkgs; [
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
