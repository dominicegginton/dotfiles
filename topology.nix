{ pkgs, config, ... }:

with pkgs.lib;
with config.lib.topology;

{
  networks = {
    internet = {
      name = "WAN Internet";
      style = {
        primaryColor = "#ff0000ff";
        pattern = "solid";
      };
    };
    quarndon = {
      name = "LAN Quarndon";
      cidrv4 = "192.168.1.0/24";
      cidrv6 = "fd00:1::/64";
      style = {
        primaryColor = "#702383ff";
        pattern = "solid";
      };
    };
    ribble = {
      name = "LAN Ribble";
      cidrv4 = "192.168.1.0/24";
      cidrv6 = "fd00:1::/64";
      style = {
        primaryColor = "#702383ff";
        pattern = "solid";
      };
    };
    quardon-nvr = {
      name = "LAN NVR Quarndon";
      cidrv4 = "192.168.1.0/24";
      cidrv6 = "fd00:3::/64";
      style = {
        primaryColor = "#a52670ff";
        pattern = "solid";
      };
    };
    pixel-9 = {
      name = "Pixel 9 Hotspot";
      cidrv4 = "100.100.100.100/24";
      cidrv6 = "fd00:2::/64";
      style = {
        primaryColor = "#9b70ebff";
        secondaryColor = "transparent";
        pattern = "solid";
      };
    };
    "${tailnet}" = {
      name = tailnet;
      cidrv4 = "100.100.100.100/24";
      cidrv6 = "fd00:2::/64";
      style = {
        primaryColor = "#70a5eb";
        secondaryColor = "transparent";
        pattern = "dashed";
      };
    };
  };
  nodes = {
    internet = mkInternet { };
    quardon-vm-modem = mkDevice "Virgin Media Super Hub" {
      info = "Virgin Media Super Hub (Disabled WiFi & Routing - Modem Only)";
      interfaceGroups = [ [ "coax" "eth1" ] ];
      interfaces.coax = {
        type = "coaxial";
        network = "internet";
        physicalConnections = [ (mkConnection "internet" "*") ];
      };
      interfaces.eth1 = {
        type = "ethernet";
        physicalConnections = [ (mkConnection "quardon-router" "eth0") ];
      };
    };
    quardon-router = mkRouter "Unifi Security Gateway" {
      info = "Unifi Security Gateway";
      interfaceGroups = [ [ "eth0" ] [ "eth1" ] ];
      interfaces.eth0 = {
        network = "internet";
        addresses = [ "dhcp" ];
        type = "ethernet";
      };
      interfaces.eth1 = {
        network = "quarndon";
        addresses = [ "192.168.1.1" ];
        type = "ethernet";
      };
    };
    quardon-switch-main = mkSwitch "Cisco Switch 24 Port" {
      info = "Cisco Switch 24 Port";
      connections.eth0 = mkConnection "quardon-router" "eth1";
      connections.eth2 = mkConnection "quardon-ap-downstairs" "eth0";
      connections.eth3 = mkConnection "quardon-ap-upstairs" "eth0";
      connections.eth4 = mkConnection "quardon-nvr" "eth0";
    };
    quardon-ap-downstairs = mkDevice "Downstairs Wireless Unifi Access Point" {
      info = "Unifi AP Light";
      interfaceGroups = [ [ "eth0" "wlan0" ] ];
      interfaces.wlan0 = {
        network = "quarndon";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-upstairs" "wlan0")
        ];
      };
    };
    quardon-ap-upstairs = mkDevice "Upstairs Wireless Unifi Access Point" {
      info = "Unifi AP Light";
      interfaceGroups = [ [ "eth0" "wlan0" ] ];
      interfaces.wlan0 = {
        network = "quarndon";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-downstairs" "wlan0")
        ];
      };
    };
    quardon-nvr = mkDevice "Reolink NVR" {
      info = "Reolink Network Video Recorder (NVR)";
      deviceIcon = ./assets/reolink.svg;
      interfaceGroups = [ [ "eth0" ] [ "eth1" "eth2" ] ];
      interfaces.eth0 = {
        network = "quarndon";
        type = "ethernet";
      };
      interfaces.eth1 = {
        network = "quardon-nvr";
        type = "ethernet";
        physicalConnections = [ (mkConnection "quardon-front-security-camera" "eth0") ];
      };
      interfaces.eth2 = {
        network = "quardon-nvr";
        type = "ethernet";
        physicalConnections = [ (mkConnection "quardon-back-security-camera" "eth0") ];
      };
    };
    quardon-front-center-security-camera = mkDevice "Reolink PTZ Front Center Security Camera" {
      info = "Reolink PTZ Security Camera Wifi";
      deviceIcon = ./assets/reolink.svg;
      interfaces.wlan0 = {
        network = "quarndon";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
        ];
      };
    };
    quardon-front-security-camera = mkDevice "Reolink Front Security Camera" {
      info = "Reolink Security Camera";
      deviceIcon = ./assets/reolink.svg;
      interfaces.eth0 = { };
    };
    quardon-back-security-camera = mkDevice "Reolink Back Security Camera" {
      info = "Reolink Security Camera";
      deviceIcon = ./assets/reolink.svg;
      interfaces.eth0 = { };
    };
    quardon-office-desktop = mkDevice "Matt's Desktop Office PC" {
      info = "Desktop All In One PC";
      deviceIcon = ./assets/windows.svg;
      interfaces.wlan0 = {
        network = "quarndon";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
        ];
      };
    };
    quardon-move-speaker = mkDevice "Sonos Move Speaker" {
      info = "Sonos Move Speaker";
      deviceIcon = ./assets/sonos.svg;
      interfaces.wlan0 = {
        network = "quarndon";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
        ];
      };
    };
    quardon-familyrooom-speaker = mkDevice "Family Room Speaker" {
      info = "Sonos One Speaker";
      deviceIcon = ./assets/sonos.svg;
      interfaces.wlan0 = {
        network = "quarndon";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
        ];
      };
    };
    quardon-livingroom-tv = mkDevice "Living Room TV" {
      info = "Smart TV";
      interfaces.wlan0 = {
        network = "quarndon";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
        ];
      };
    };
    quardon-livingroom-speaker = mkDevice "Living Room Speaker" {
      info = "Sonos Soundbar";
      deviceIcon = ./assets/sonos.svg;
      interfaces.wlan0 = {
        network = "quarndon";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
        ];
      };
    };
    quardon-master-bedroom-tv = mkDevice "Master Bedroom TV" {
      info = "Samsung Smart TV";
      interfaces.wlan0 = {
        network = "quarndon";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
        ];
      };
    };
    quardon-master-bedroom-google-tv = mkDevice "Master Bedroom Google TV" {
      info = "Google Chromecast with Google TV 4K";
      deviceIcon = ./assets/google.svg;
      interfaces.wlan0 = {
        network = "quarndon";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
        ];
      };
    };
    quardon-bedroom-speaker = mkDevice "Bedroom Speaker" {
      info = "Sonos One Speaker";
      deviceIcon = ./assets/sonos.svg;
      interfaces.wlan0 = {
        network = "quarndon";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
        ];
      };
    };
    ribble-fiber-modem = mkDevice "EE Fiber Modem" {
      info = "EE Fiber Modem";
      interfaceGroups = [ [ "fiber" "eth1" ] ];
      interfaces.fiber = {
        network = "internet";
        type = "fiber-duplex";
        physicalConnections = [ (mkConnection "internet" "*") ];
      };
      interfaces.eth1 = {
        type = "ethernet";
        physicalConnections = [ (mkConnection "ribble-router" "eth0") ];
      };
    };
    ribble-router = mkRouter "EE Router" {
      info = "EE Router";
      interfaceGroups = [ [ "eth0" ] [ "wlan0" "eth1" "eth2" "eth3" "eth4" ] ];
      interfaces.eth0 = {
        network = "internet";
        addresses = [ "dhcp" ];
        type = "ethernet";
      };
      interfaces.eth1 = {
        network = "ribble";
        addresses = [ "192.168.1.1" ];
        type = "ethernet";
      };
      interfaces.wlan0 = {
        network = "ribble";
        addresses = [ "192.168.1.1" ];
        type = "wifi";
      };
    };
    ribble-switch = mkSwitch "Switch" {
      info = "Switch";
      interfaceGroups = [ [ "eth0" "eth1" "eth2" "eth3" "eth4" "eth5" "eth6" "eth7" "eth8" "eth9" "eth10" "eth11" "eth12" "eth13" "eth14" "eth15" "eth16" ] ];
      connections.eth0 = mkConnection "ribble-router" "eth1";
      connections.eth1 = mkConnection "ribble-security-camera" "eth0";
    };
    ribble-security-camera = mkDevice "Doorbell Camera" {
      info = "Reolink Doorbell Camera";
      deviceIcon = ./assets/reolink.svg;
      interfaces.eth0 = {
        network = "ribble";
        type = "ethernet";
        physicalConnections = [ (mkConnection "ribble-switch" "eth1") ];
      };
    };
    ribble-livingroom-google-tv = mkDevice "Living Room Google TV" {
      info = "Google Chromecast with Google TV 1080p";
      deviceIcon = ./assets/google.svg;
      interfaces.wlan0 = {
        network = "ribble";
        type = "wifi";
        physicalConnections = [ (mkConnection "ribble-router" "wlan0") ];
      };
    };
    ribble-livingroom-lamp-switch = mkDevice "Lamp" {
      info = "Sonoff Living Room Lamp Switch";
      interfaces.wlan0 = {
        network = "ribble";
        type = "wifi";
        physicalConnections = [ (mkConnection "ribble-router" "wlan0") ];
      };
    };
    ribble-kitchen-lamp-switch = mkDevice "Shelf Lamp" {
      info = "Sonoff Kitchen Lamp Switch";
      interfaces.wlan0 = {
        network = "ribble";
        type = "wifi";
        physicalConnections = [ (mkConnection "ribble-router" "wlan0") ];
      };
    };
    ribble-office-lamp-switch = mkDevice "Desk Lamp" {
      info = "Sonoff Office Lamp Switch";
      interfaces.wlan0 = {
        network = "ribble";
        type = "wifi";
        physicalConnections = [ (mkConnection "ribble-router" "wlan0") ];
      };
    };
    ribble-bedroom-lamps-switch = mkDevice "Bedside Lights" {
      info = "Sonoff Bedroom Lamps Switch";
      interfaces.wlan0 = {
        network = "ribble";
        type = "wifi";
        physicalConnections = [ (mkConnection "ribble-router" "wlan0") ];
      };
    };
    ribble-bedroom-speaker = mkDevice "Dom's Bedroom Speaker" {
      info = "Google Home Bedroom Speaker";
      deviceIcon = ./assets/google.svg;
      interfaces.wlan0 = {
        network = "ribble";
        type = "wifi";
        physicalConnections = [ (mkConnection "ribble-router" "wlan0") ];
      };
    };
    mccml44wmd6t = mkDevice "MCCML44WMD6T" {
      info = "Macbook Pro 2019 - Arup Workstation";
      deviceIcon = ./assets/apple.svg;
      interfaces.wlan0 = {
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
          (mkConnection "ribble-router" "wlan0")
        ];
      };
      interfaces.tailscale0 = {
        network = tailnet;
        type = "tailscale";
        icon = ./assets/tailscale.svg;
        virtual = true;
        addresses = [ "mccml44wmd6t" "mccml44wmd6t.${tailnet}" ];
      };
    };

    pixel-9 = mkDevice "pixel-9" {
      info = "Google Pixel 9";
      deviceIcon = ./assets/google.svg;
      interfaces."5g-radio" = {
        type = "cellular";
        network = "internet";
        physicalConnections = [ (mkConnection "internet" "*") ];
      };
      interfaces.hotspot = {
        network = "pixel-9";
        type = "wifi";
      };
      interfaces.wlan0 = {
        network = "ribble";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
          (mkConnection "ribble-router" "wlan0")
        ];
      };
      interfaces.tailscale0 = {
        network = tailnet;
        type = "tailscale";
        icon = ./assets/tailscale.svg;
        virtual = true;
        addresses = [ "pixel-9" "pixel-9.${tailnet}" ];
      };
    };
    steamdeck = mkDevice "steamdeck" {
      info = "Steam Deck";
      interfaces.wlan0 = {
        network = "ribble";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
          (mkConnection "ribble-router" "wlan0")
          (mkConnection "pixel-9" "hotspot")
        ];
      };
      interfaces.tailscale0 = {
        network = tailnet;
        type = "tailscale";
        icon = ./assets/tailscale.svg;
        virtual = true;
        addresses = [ "steamdeck" "steamdeck.${tailnet}" ];
      };
    };
  };
}
