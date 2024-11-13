{ pkgs ? import <nixpkgs> { config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [ "vscode" "vscode-with-extensions" ]; } }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    (python3.withPackages (pythonPkgs: with pythonPkgs; [
      pyright
      jupyterlab
      notebook
    ]))
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
