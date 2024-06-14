{ inputs
, pkgs
, ...
}:

{
  imports = [
    inputs.nixos-hardware.nixosModules.dell-latitude-7390
    ./disks.nix
    ./boot.nix
  ];

  hardware.mwProCapture.enable = true;
  services.logind.extraConfig = "HandlePowerKey=suspend";
  services.logind.lidSwitch = "suspend";

  modules = {
    networking.enable = true;
    networking.hostname = "latitude-7390";
    networking.wireless = true;
    virtualisation.enable = true;
    bluetooth.enable = true;
    users.dom.enable = true;
    desktop.sway.enable = true;
    desktop.packages = with pkgs; [
      thunderbird
      archi
      unstable.teams-for-linux
      unstable.chromium
    ];
  };
}
