{
  stdenv,
  fetchFromGitHub,
  lib,
  nixosTests,
  buildPackages,
  unzip,
}:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-dynamic-music-pill";
  version = "V2.1.1";

  src = fetchFromGitHub {
    owner = "andbal";
    repo = "dynamic-music-pill";
    rev = "v${version}";
    sha256 = "sha256-nkwH2WvsOxUy8P637Pol7cNuehJzzzH78ZjbLLfNOkU=";
  };

  nativeBuildInputs = [
    buildPackages.glib
    unzip
  ];

  buildPhase = ''
    runHook preBuild
    if [ -d schemas ]; then
      glib-compile-schemas --strict schemas
    fi
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/gnome-shell/extensions/
    cp -r -T . $out/share/gnome-shell/extensions/${uuid}
    runHook postInstall
  '';

  meta = {
    description = builtins.head (lib.splitString "\n" description);
    longDescription = description;
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
  };
  uuid = "dynamic-music-pill@andbal";
  name = "Dynamic Music Pill";
  description = "An elegant, pill-shaped music player for your desktop. Features a smooth audio visualizer, scrolling text, and seamless integration with Dash-to-Dock and the Top Panel.";

  passthru = {
    extensionPortalSlug = pname;
    extensionUuid = uuid;
    tests = {
      gnome-extensions = nixosTests.gnome-extensions;
    };
  };
}
