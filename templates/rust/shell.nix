{ pkgs }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    rustc
    cargo
    rust-analyzer
    rustfmt
  ];

  shellHook = ''
    export CARGO_HOME=$PWD/.cargo
    export PATH=$CARGO_HOME/bin:$PATH
  '';
}
