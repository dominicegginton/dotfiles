{ lib, mkShell, jdk, androidsdk, android-tools, android-studio }:

mkShell {
  ANDROID_HOME = "${androidsdk}/libexec";
  nativeBuildInputs = [
    (lib.development-promt "temp android shell")
    jdk
    androidsdk
    android-tools
    android-studio
  ];
}
