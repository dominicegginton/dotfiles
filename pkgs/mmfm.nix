{
  pkgs,
  fetchFromGitHub,
  lib,
  stdenv,
}:
stdenv.mkDerivation {
  pname = "mmfm";
  version = "0.53b";

  src = fetchFromGitHub {
    owner = "milgra";
    repo = "mmfm";
    rev = "2b07457";
    sha256 = "sha256-FwXF1pwK+p9fh6dlH+c/Ads5v9Q2OyzZuo+MtvnQgGA=";
  };

  nativeBuildInputs = with pkgs; [
    # build
    pkg-config
  ];

  buildInputs = with pkgs; [
    # build
    meson
    ninja
    # ui rendering and input
    wayland
    wayland-protocols
    glew
    freetype
    libxkbcommon

    ffmpeg
    libpng
    libav
    libopenmpt
    libharu
    mupdf

    gumbo
    mujs
  ];

  makeFlags = ["prefix=$(out)" "USE_SYSTEM_LIBS=yes"];
  enableParallelBuilding = true;

  configurePhase = ''
    USE_SYSTEM_LIBS=yes


  '';

  buildPhase = ''
    meson build --buildtype=release
    # ninja -C build
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp build/mmfm $out/bin

    mkdir - p $out/share
    cp -r data $out/share/mmfm
  '';
}
