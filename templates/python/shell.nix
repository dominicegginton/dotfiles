{ pkgs }:
with pkgs;
mkShell {
  packages = with pkgs; [
    (python3.withPackages (python-pkgs: [
      python-pkgs.flask
    ]))
  ];
}
