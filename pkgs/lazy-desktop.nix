{ lib, stdenv, nix-index, desktop-file-utils }:

let
  nix-index-database = builtins.fetchurl {
    name = "nix-index-database";
    url = "https://github.com/nix-community/nix-index-database/releases/download/2025-09-14-032502/index-x86_64-linux";
    sha256 = "16dc5881f6766beb731ad2bbe6a8bf23a8b2e25a84b971a71d65cafcaff7cc92";
  };
in

stdenv.mkDerivation {
  name = "karren.lazy-desktop";
  buildInputs = [ nix-index desktop-file-utils ];
  dontUnpack = true;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/share/applications
    ln -s ${nix-index-database} files
    nix-locate \
      --db . \
      --minimal \
      --regex \
      '/share/applications/.*\.desktop$' \
      | while read -r package
      do
        cat > $out/share/applications/"$package.desktop" << EOF
    [Desktop Entry]
    Version=1.0
    Name="Lazy: $package"
    Type=Application
    Exec=nix run "nixpkgs#$package"
    Terminal=false
    Categories=Utility;
    Comment="Run the package $package using nix run"
    EOF
        desktop-file-validate $out/share/applications/"$package.desktop"
      done
  '';
  meta = {
    deskscription = "A package with desktop files for all packages in the nix-index database";
    longDescription = ''
      A package with desktop files for all packages in the nix-index database.

      When a .desktop is executed it will run the package using `nix run nixpkgs#package`.
    '';
    maintainers = [ lib.maintainers.dominicegginton ];
    platforms = [ "x86_64-linux" ];
  };
}
