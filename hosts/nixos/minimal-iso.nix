{ modulesPath, ... }:

{
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];
  nix.settings.experimental-features = "nix-command flakes";
  services.openssh.enable = true;
}
