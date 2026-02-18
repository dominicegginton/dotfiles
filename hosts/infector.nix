{
  self,
  lib,
  pkgs,
  config,
  modulesPath,
  ...
}:

let
  nixosConfiguration = builtins.getEnv "NIXOS_CONFIGURATION";
in

let
  childInputs = child: if child ? inputs && child.inputs != { } then (collector child) else [ ];

  collect = child: [ child.outPath ] ++ childInputs child;

  collector = parent: map collect (lib.attrValues parent.inputs);

  flakeOutPaths = lib.unique (lib.flatten (collector self));

  dependencies = flakeOutPaths ++ [
    self.nixosConfigurations.${nixosConfiguration}.config.system.build.toplevel
    self.nixosConfigurations.${nixosConfiguration}.config.system.build.diskoScript
    self.nixosConfigurations.${nixosConfiguration}.config.system.build.diskoScript.drvPath
    self.nixosConfigurations.${nixosConfiguration}.pkgs.stdenv.drvPath
    self.nixosConfigurations.${nixosConfiguration}.pkgs.perlPackages.ConfigIniFiles
    self.nixosConfigurations.${nixosConfiguration}.pkgs.perlPackages.FileSlurp
    (self.nixosConfigurations.${nixosConfiguration}.pkgs.closureInfo { rootPaths = [ ]; }).drvPath
  ];

  closureInfo = pkgs.closureInfo { rootPaths = dependencies; };
in

{
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-base.nix") ];

  image.baseName = lib.mkDefault "${config.nixos.distroId}-installer";

  console.earlySetup = true;

  services.openssh.enable = true;

  services.getty.autologinUser = lib.mkForce "root";

  networking.tempAddresses = "disabled";

  systemd.tmpfiles.rules = [ "d /var/shared 0777 root root - -" ];

  system.activationScripts.root-password = ''
    mkdir -p /var/shared
    ${pkgs.xkcdpass}/bin/xkcdpass --numwords 3 --delimiter - --count 1 > /var/shared/root-password
    echo "root:$(cat /var/shared/root-password)" | chpasswd
  '';

  environment.etc."install-closure".source = "${closureInfo}/store-paths";

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "unattended-install" ''
      set -eux

      ${pkgs.networkmanager}/bin/nmcli device wifi connect --ask

      exec ${pkgs.disko}/bin/disko-install \
        --flake "${self}#${nixosConfiguration}" \
        --disk main /dev/sda

      ${pkgs.google-cloud-sdk}/bin/gcloud auth login --brief --no-launch-browser

      ${pkgs.gsutil}/bin/gsutil cp gs://installer-secrets/installer-gpg-key /mnt/root-gpg-key.asc
      ${pkgs.coreutils}/bin/chroot /mnt /bin/bash -c "gpg --import /root-gpg-key.asc && rm /root-gpg-key.asc"
    '')
  ];
}
