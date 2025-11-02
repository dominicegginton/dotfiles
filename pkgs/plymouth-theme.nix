{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "colorful";
  src = fetchFromGitHub {
    owner = "adi1090x";
    repo = "plymouth-themes";
    rev = "master";
    sha256 = "sha256-e3lRgIBzDkKcWEp5yyRCzQJM6yyTjYC5XmNUZZroDuw=";
  };
  installPhase = ''
    mkdir -p $out/share/plymouth/themes/colorful
    cd pack_1/colorful
    cp *png colorful.script colorful.plymouth $out/share/plymouth/themes/colorful/
    chmod +x $out/share/plymouth/themes/colorful/colorful.plymouth $out/share/plymouth/themes/colorful/colorful.script
    sed -i "s@/usr/@$out/@" $out/share/plymouth/themes/colorful/colorful.plymouth
  '';
}
