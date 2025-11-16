{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "colorful";
  src = fetchFromGitHub {
    owner = "adi1090x";
    repo = "plymouth-themes";
    rev = "master";
    sha256 = "sha256-e3lRgIBzDkKcWEp5yyRCzQJM6yyTjYC5XmNUZZroDuw=";
  };
  pack = "pack_1";
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/plymouth/themes/${name}
    cd ${pack}/${name}
    cp *png ${name}.script ${name}.plymouth $out/share/plymouth/themes/${name}/
    chmod +x $out/share/plymouth/themes/${name}/${name}.plymouth $out/share/plymouth/themes/${name}/${name}.script
    sed -i "s@/usr/@$out/@" $out/share/plymouth/themes/${name}/${name}.plymouth
  
    runHook postInstall
  '';
}
