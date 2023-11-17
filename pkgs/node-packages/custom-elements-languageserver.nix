{pkgs, ...}:
pkgs.buildNpmPackage rec {
  pname = "custom-elements-languageserver";
  version = "1.0.4";
  buildInputs = with pkgs; [vscode vsce];
  src = pkgs.fetchFromGitHub {
    owner = "Matsuuu";
    repo = "custom-elements-language-server";
    rev = "v.${version}";
    hash = "sha256-VgormZQbwLTW7rLrbDZKtqFz+USBYvq/jR1IGCwdcmk=";
  };
  npmDepsHash = "sha256-/EMFHcFOKapAKXKVyoLV17G+UvIyZhyS2gWxp9Z7uTE=";
  npmBuildScript = "bundle";
}
