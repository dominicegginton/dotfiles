{ lib, stdenv, nix-index, desktop-file-utils }:
stdenv.mkDerivation {
  name = "karren.lazy-desktop";
  buildInputs = [ nix-index desktop-file-utils ];
  dontUnpack = true;
  dontBuild = true;
  installPhase =
    let
      nix-index-database = builtins.fetchurl {
        url = "https://github.com/nix-community/nix-index-database/releases/download/2025-07-06-034719/index-x86_64-linux";
        sha256 = "b8f0b5d94d2b43716e4f0e26dbc9f141b238c3f516618b592c2a9435cdacd8a1";
      };
    in
    ''
      mkdir -p $out/share/applications
      ln -s ${nix-index-database} files
      nix-locate \
        --db . \
        --top-level \
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
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ dominicegginton ];
    description = ''
      A package with desktop files for all packages in the nix-index database.
      When a .desktop is executed it will run the package using `nix run nixpkgs#package`.
    '';
  };
}
