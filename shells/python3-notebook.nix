{ lib, mkShell, python3, vscode-with-extensions, vscode-extensions }:

let
  NOTEBOOK = builtins.getEnv "NOTEBOOK";
in

mkShell {
  name = "ad-hoc python3-notebook";
  packages = [
    (python3.withPackages (python-pkgs: with python-pkgs; [
      ipython
      ipykernel
      numpy
      pandas
      matplotlib
      seaborn
      urllib3
    ]))
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        ms-python.python
        ms-toolsai.jupyter
      ];
    })
  ];
  shellHook =
    if (NOTEBOOK != "") then
      assert builtins.pathExists NOTEBOOK;
      ''
        code ${NOTEBOOK}
      ''
    else
      '''';
  meta.maintainers = [ lib.maintainers.dominicegginton ];
}
