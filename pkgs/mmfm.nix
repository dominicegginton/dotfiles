{
  pkgs,
  fetchFromGitHub,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "mmfm";
  version = "0.53b";
  src = fetchFromGitHub {
    owner = "milgra";
    repo = "mmfm";
    rev = "2b07457";
    sha256 = "sha256-FwXF1pwK+p9fh6dlH+c/Ads5v9Q2OyzZuo+MtvnQgGA=";
  };
  nativeBuildInputs = with pkgs; [
    meson
    ninja
    pkg-config
  ];
  buildInputs = with pkgs; [
    wayland
    wayland-protocols
    glew
    freetype
    libxkbcommon
    ffmpeg
    libpng
    libjpeg
    jbig2dec
    openjpeg
    harfbuzz
    libav
    libopenmpt
    libharu
    mupdf_1_17
    SDL2
    gumbo
    mujs
  ];
}
