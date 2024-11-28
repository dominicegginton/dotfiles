{ modulesPath, inputs, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    inputs.nixos-images.nixosModules.image-installer
  ];
  nix.settings.experimental-features = "nix-command flakes";
  services.openssh.enable = true;
}
