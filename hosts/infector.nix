{
  self,
  lib,
  pkgs,
  config,
  modulesPath,
  ...
}:

let
  # Get the target NixOS configuration from environment
  nixosConfiguration = builtins.getEnv "NIXOS_CONFIGURATION";
in

let
  # Recursively collect all flake input paths for the closure
  childInputs = child: if child ? inputs && child.inputs != { } then (collector child) else [ ];

  collect = child: [ child.outPath ] ++ childInputs child;

  collector = parent: map collect (lib.attrValues parent.inputs);

  flakeOutPaths = lib.unique (lib.flatten (collector self));

  # Define all dependencies required for an offline/unattended installation
  dependencies = flakeOutPaths ++ [
    self.nixosConfigurations.${nixosConfiguration}.config.system.build.toplevel
    self.nixosConfigurations.${nixosConfiguration}.config.system.build.diskoScript
    self.nixosConfigurations.${nixosConfiguration}.config.system.build.diskoScript.drvPath
    self.nixosConfigurations.${nixosConfiguration}.pkgs.stdenv.drvPath
    self.nixosConfigurations.${nixosConfiguration}.pkgs.perlPackages.ConfigIniFiles
    self.nixosConfigurations.${nixosConfiguration}.pkgs.perlPackages.FileSlurp
    (self.nixosConfigurations.${nixosConfiguration}.pkgs.closureInfo { rootPaths = [ ]; }).drvPath
  ];

  # Generate closure information for the installer
  closureInfo = pkgs.closureInfo { rootPaths = dependencies; };
in

{
  # Base installer image
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-base.nix") ];

  image.baseName = lib.mkDefault "${config.nixos.distroId}-installer";

  console.earlySetup = true;

  # Enable SSH for remote access during installation
  services.openssh.enable = true;

  # Auto-login as root for ease of use
  services.getty.autologinUser = lib.mkForce "root";

  networking.tempAddresses = "disabled";

  # Create a shared directory for password transfer
  systemd.tmpfiles.rules = [ "d /var/shared 0777 root root - -" ];

  # Generate a random root password and store it in /var/shared
  system.activationScripts.root-password = ''
    mkdir -p /var/shared
    ${pkgs.xkcdpass}/bin/xkcdpass --numwords 3 --delimiter - --count 1 > /var/shared/root-password
    echo "root:$(cat /var/shared/root-password)" | chpasswd
  '';

  # Provide the list of store paths required for the installation
  environment.etc."install-closure".source = "${closureInfo}/store-paths";

  # Custom installation script
  environment.systemPackages = [
    (pkgs.writeShellScript "custom-install-script" ''
      # ...
    '')
  ];

  # Disable Beszel monitoring for the installer
  services.beszel.enable = lib.mkForce false;
}
