{ self, lib, config, platform, ... }:

{
  nixpkgs.hostPlatform = lib.mkDefault platform;

  imports = with self.inputs.nixos-hardware.nixosModules; [ common-pc-laptop common-pc-laptop-ssd dell-latitude-7390 ];

  # TODO: swap to btrfs
  fileSystems."/".device = "/dev/disk/by-uuid/2d59d3c7-44f3-4fd3-9c7a-64b2ec9f21a0";
  fileSystems."/".fsType = "ext4";
  fileSystems."/boot".device = "/dev/disk/by-uuid/8543-16DB";
  fileSystems."/boot".fsType = "vfat";
  swapDevices = [{ device = "/dev/disk/by-uuid/4e74fa9d-47d7-4a43-9cec-01d4fdd1a1a2"; }];

  hardware = {
    # TODO: swap to btrfs 
    # disks.root.id = "/dev/sda";

    bluetooth.enable = true;
    intel-gpu-tools.enable = true;
    logitech = {
      wireless = {
        enable = true;
        enableGraphical = true;
      };
    };
  };

  boot = {
    kernelModules = [ "kvm-intel" "vhost_vsock" "i2c-dev" "ddcci_backlight" ];
    extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
  };

  display.gnome.enable = true;

  services = {
    logind.settings.Login.HandleLidSwitchDocked = "suspend";
    upower.enable = true;
    tlp = {
      enable = true;
      batteryThreshold.enable = true;
    };
    usbguard.rules = ''
      allow id 1d6b:0002 serial "0000:00:14.0" name "xHCI Host Controller" hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" parent-hash "rV9bfLq7c2eA4tYjVjwO4bxhm+y6GgZpl9J60L0fBkY=" with-interface 09:00:00 with-connect-type ""
      allow id 1d6b:0003 serial "0000:00:14.0" name "xHCI Host Controller" hash "3Wo3XWDgen1hD5xM3PSNl3P98kLp1RUTgGQ5HSxtf8k=" parent-hash "rV9bfLq7c2eA4tYjVjwO4bxhm+y6GgZpl9J60L0fBkY=" with-interface 09:00:00 with-connect-type ""
      allow id 1d6b:0002 serial "0000:37:00.0" name "xHCI Host Controller" hash "Nqe34Aq1aYNBGK8WI2u5jL//Ivps6Bd/RXF8a8HhC5U=" parent-hash "OuhpyIUyVyDxrPnYaGwYTrUHnTrAheAsRygYxrOT+H0=" with-interface 09:00:00 with-connect-type ""
      allow id 1d6b:0003 serial "0000:37:00.0" name "xHCI Host Controller" hash "zRY266loBH7GIz2ifvCWu1vhsoT5HODoGjsUGUJzTKQ=" parent-hash "OuhpyIUyVyDxrPnYaGwYTrUHnTrAheAsRygYxrOT+H0=" with-interface 09:00:00 with-connect-type ""
      allow id 0bda:58f6 serial "200901010001" name "Integrated_Webcam_HD" hash "63/xld67bmuT9aMNMx5KZ8ZzjbIYhD2g7y7tr9NuJVY=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" with-interface { 0e:01:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:01:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 } with-connect-type "hardwired"
      allow id 8087:0a2b serial "" name "" hash "TtRMrWxJil9GOY/JzidUEOz0yUiwwzbLm8D7DJvGxdg=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" via-port "1-7" with-interface { e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 } with-connect-type "hardwired"
      allow id 0bda:0328 serial "28203008282014000" name "USB3.0-CRW" hash "+rdt/gUNicD/8xJnaFeMXunM1SNJu2bCHm5XxuDZ3uQ=" parent-hash "3Wo3XWDgen1hD5xM3PSNl3P98kLp1RUTgGQ5HSxtf8k=" with-interface 08:06:50 with-connect-type "hardwired"
      allow id 0451:8442 serial "390208512ACF" name "" hash "i8BVhpRxFr+upCHicKe82gWWmI2sPV2rLolRpTNPwhc=" parent-hash "Nqe34Aq1aYNBGK8WI2u5jL//Ivps6Bd/RXF8a8HhC5U=" with-interface { 09:00:01 09:00:02 } with-connect-type "hotplug"
      allow id 0451:8442 serial "9A0208412ACF" name "" hash "DlsTh2GxGfnUXPXVK1SOudjsyGxMnQ/btuHJocDjTlY=" parent-hash "Nqe34Aq1aYNBGK8WI2u5jL//Ivps6Bd/RXF8a8HhC5U=" with-interface { 09:00:01 09:00:02 } with-connect-type "hotplug"
      allow id 0451:8440 serial "" name "" hash "zSE9+mL7oNP12rU6WvaME9/ZcSl28k+JavUbxtxzYdQ=" parent-hash "zRY266loBH7GIz2ifvCWu1vhsoT5HODoGjsUGUJzTKQ=" via-port "4-1" with-interface 09:00:00 with-connect-type "hotplug"
      allow id 0451:8440 serial "" name "" hash "zSE9+mL7oNP12rU6WvaME9/ZcSl28k+JavUbxtxzYdQ=" parent-hash "zRY266loBH7GIz2ifvCWu1vhsoT5HODoGjsUGUJzTKQ=" via-port "4-2" with-interface 09:00:00 with-connect-type "hotplug"
      allow id 0a5c:5834 serial "0123456789ABCD" name "5880" hash "+YH06PbcYGU42XrDqMUVVHrSxEvBe75boTfjxlh6cnQ=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" with-interface { fe:00:00 0b:00:00 0b:00:00 ff:00:00 } with-connect-type "hardwired"
      allow id 046d:c52b serial "" name "USB Receiver" hash "djeL7wNsJBQMuBiqUyWflgupndhsbPkbOih8g3L6OeA=" parent-hash "i8BVhpRxFr+upCHicKe82gWWmI2sPV2rLolRpTNPwhc=" via-port "3-1.1" with-interface { 03:01:01 03:01:02 03:00:00 } with-connect-type "unknown"
      allow id 05ac:0250 serial "" name "Keychron K2" hash "qa1ZDUxjwXfYDXW+dQY8ySd/TwHubB4ON8qrFsXKn4E=" parent-hash "i8BVhpRxFr+upCHicKe82gWWmI2sPV2rLolRpTNPwhc=" via-port "3-1.2" with-interface { 03:01:01 03:01:02 } with-connect-type "unknown"
      allow id 0451:82ff serial "" name "" hash "y1IP3wHahAPyS1jcoBvVlQZSGWFT0qVh95RW4FG/W68=" parent-hash "i8BVhpRxFr+upCHicKe82gWWmI2sPV2rLolRpTNPwhc=" via-port "3-1.5" with-interface 03:00:00 with-connect-type "unknown"
      allow id b58e:0005 serial "8839B14181040506" name "Yeti Nano" hash "iaKO0NXnK1mGu/OU2CX6mGogszjA44Bcy+XsNjwgbOM=" parent-hash "DlsTh2GxGfnUXPXVK1SOudjsyGxMnQ/btuHJocDjTlY=" with-interface { 01:01:00 01:02:00 01:02:00 01:02:00 01:02:00 03:00:00 } with-connect-type "unknown"
      allow id 0451:82ff serial "" name "" hash "y1IP3wHahAPyS1jcoBvVlQZSGWFT0qVh95RW4FG/W68=" parent-hash "DlsTh2GxGfnUXPXVK1SOudjsyGxMnQ/btuHJocDjTlY=" via-port "3-2.5" with-interface 03:00:00 with-connect-type "unknown"
    '';
  };

  programs = {
    vscode.enable = true;
    firefox.enable = true;
  };

  virtualisation.docker.enable = true;

  topology.self.hardware.info = "Workstation";
}
