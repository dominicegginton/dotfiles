{ pkgs }:

pkgs.mkShell {
  buildInputs = with pkgs; [ rustc cargo ];
}
