{ mkShell, jdk, androidsdk, android-tools, android-studio }:

mkShell {
  ANDROID_HOME = "${androidsdk}/libexec";
  nativeBuildInputs = [ jdk androidsdk android-tools android-studio ];
}
