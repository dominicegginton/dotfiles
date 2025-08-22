{ pkgs, config, ... }:

with pkgs.lib;
with config.lib.topology;

{
  networks = {
    internet = {
      name = "internet";
      style = {
        primaryColor = "lightblue";
        pattern = "solid";
      };
    };
    burbage = {
      name = "burbage";
      cidrv4 = "192.168.1.0/24";
      cidrv6 = "fd00:1::/64";
      style = {
        primaryColor = "#b16286";
        pattern = "solid";
      };
    };
    cameras = {
      name = "cameras";
      cidrv4 = "192.168.1.0/24";
      cidrv6 = "fd00:3::/64";
      style = {
        primaryColor = "#dfa000";
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
    quardon-router = mkRouter "quardon-router" {
      info = "Unifi Security Gateway";
      interfaceGroups = [ [ "eth0" ] [ "eth1" ] ];
      interfaces.eth0 = {
        network = "internet";
        type = "fiber-duplex";
        physicalConnections = [ (mkConnection "internet" "*") ];
      };
      interfaces.eth1 = {
        network = "burbage";
        addresses = [ "192.168.1.1" ];
        type = "ethernet";
      };
    };
    quardon-switch-main = mkSwitch "quardon-switch-main" {
      info = "Cisco Switch 24 Port";
      connections.eth0 = mkConnection "quardon-router" "eth1";
      connections.eth2 = mkConnection "quardon-ap-downstairs" "eth0";
      connections.eth3 = mkConnection "quardon-ap-upstairs" "eth0";
      connections.eth4 = mkConnection "quardon-nvr" "eth0";
    };
    quardon-ap-downstairs = mkDevice "quardon-ap-downstairs" {
      info = "Unifi AP Light";
      interfaceGroups = [ [ "eth0" "wlan0" ] ];
      interfaces.wlan0 = {
        network = "burbage";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-upstairs" "wlan0")
        ];
      };
    };
    quardon-ap-upstairs = mkDevice "quardon-ap-upstairs" {
      info = "Unifi AP Light";
      interfaceGroups = [ [ "eth0" "wlan0" ] ];
      interfaces.wlan0 = {
        network = "burbage";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-downstairs" "wlan0")
        ];
      };
    };
    quardon-nvr = mkDevice "quardon-nvr" {
      info = "Reolink NVR";
      deviceIcon = ./assets/reolink.svg;
      interfaceGroups = [ [ "eth0" ] [ "eth1" "eth2" ] ];
      interfaces.eth0 = {
        network = "burbage";
        type = "ethernet";
      };
      interfaces.eth1 = {
        network = "cameras";
        type = "ethernet";
        physicalConnections = [
          (mkConnection "quardon-front-security-camera" "eth0")
          (mkConnection "quardon-back-security-camera" "eth0")
        ];
      };
    };
    quardon-front-center-security-camera = mkDevice "quardon-front-center-security-camera" {
      info = "Reolink PTZ Security Camera";
      deviceIcon = ./assets/reolink.svg;
      interfaces.wlan0 = {
        network = "burbage";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
        ];
      };
    };
    quardon-front-security-camera = mkDevice "quardon-front-security-camera" {
      info = "Reolink Security Camera";
      deviceIcon = ./assets/reolink.svg;
      interfaces.eth0 = { };
    };
    quardon-back-security-camera = mkDevice "quardon-back-security-camera" {
      info = "Reolink Security Camera";
      deviceIcon = ./assets/reolink.svg;
      interfaces.eth0 = { };
    };
    quardon-office-desktop = mkDevice "quardon-office-desktop" {
      info = "Desktop All In One PC";
      deviceIcon = ./assets/windows.svg;
      interfaces.wlan0 = {
        network = "burbage";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
        ];
      };
    };
    quardon-move-speaker = mkDevice "quardon-move-speaker" {
      info = "Sonos Move Speaker";
      deviceIcon = ./assets/sonos.svg;
      interfaces.wlan0 = {
        network = "burbage";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
        ];
      };
    };
    quardon-familyrooom-speaker = mkDevice "quardon-familyrooom-speaker" {
      info = "Sonos One Speaker";
      deviceIcon = ./assets/sonos.svg;
      interfaces.wlan0 = {
        network = "burbage";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
        ];
      };
    };
    quardon-livingroom-tv = mkDevice "quardon-livingroom-tv" {
      info = "Smart TV";
      interfaces.wlan0 = {
        network = "burbage";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
        ];
      };
    };
    quardon-livingroom-speaker = mkDevice "quardon-livingroom-speaker" {
      info = "Sonos Soundbar";
      deviceIcon = ./assets/sonos.svg;
      interfaces.wlan0 = {
        network = "burbage";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
        ];
      };
    };
    quardon-bedroom-tv = mkDevice "quardon-bedroom-tv" {
      info = "Google Chromecast with Google TV 4K";
      deviceIcon = ./assets/google.svg;
      interfaces.wlan0 = {
        network = "burbage";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
        ];
      };
    };
    quardon-bedroom-speaker = mkDevice "quardon-bedroom-speaker" {
      info = "Sonos One Speaker";
      deviceIcon = ./assets/sonos.svg;
      interfaces.wlan0 = {
        network = "burbage";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
        ];
      };
    };
    ribble-router = mkRouter "ribble-router" {
      info = "Unifi Security Gateway";
      interfaceGroups = [ [ "eth0" ] [ "eth1" ] ];
      interfaces.eth0 = {
        network = "internet";
        type = "fiber-duplex";
        physicalConnections = [ (mkConnection "internet" "*") ];
      };
      interfaces.eth1 = {
        network = "burbage";
        addresses = [ "192.168.1.1" ];
        type = "ethernet";
      };
      interfaces.wlan0 = {
        network = "burbage";
        type = "wifi";
      };
    };
    ribble-switch = mkSwitch "ribble-switch" {
      info = "Switch";
      interfaceGroups = [ [ "eth0" "eth1" "eth2" "eth3" ] ];
      connections.eth0 = mkConnection "ribble-router" "eth1";
      connections.eth2 = mkConnection "ribble-security-camera" "eth0";
    };
    ribble-security-camera = mkDevice "ribble-security-camera" {
      info = "Reolink Doorbell Camera";
      deviceIcon = ./assets/reolink.svg;
      interfaces.eth0 = { };
    };
    ribble-livingroom-tv = mkDevice "ribble-livingroom-tv" {
      info = "Google Chromecast with Google TV 1080p";
      deviceIcon = ./assets/google.svg;
      interfaces.wlan0 = {
        network = "burbage";
        type = "wifi";
        physicalConnections = [ (mkConnection "ribble-router" "wlan0") ];
      };
    };
    ribble-livingroom-lamp-switch = mkDevice "ribble-livingroom-lamp-switch" {
      info = "Sonoff Living Room Lamp Switch";
      interfaces.wlan0 = {
        network = "burbage";
        type = "wifi";
        physicalConnections = [ (mkConnection "ribble-router" "wlan0") ];
      };
    };
    ribble-kitchen-lamp-switch = mkDevice "ribble-kitchen-lamp-switch" {
      info = "Sonoff Kitchen Lamp Switch";
      interfaces.wlan0 = {
        network = "burbage";
        type = "wifi";
        physicalConnections = [ (mkConnection "ribble-router" "wlan0") ];
      };
    };
    ribble-office-lamp-switch = mkDevice "ribble-office-lamp-switch" {
      info = "Sonoff Office Lamp Switch";
      interfaces.wlan0 = {
        network = "burbage";
        type = "wifi";
        physicalConnections = [ (mkConnection "ribble-router" "wlan0") ];
      };
    };
    ribble-bedroom-lamps-switch = mkDevice "ribble-bedroom-lamps-switch" {
      info = "Sonoff Bedroom Lamps Switch";
      interfaces.wlan0 = {
        network = "burbage";
        type = "wifi";
        physicalConnections = [ (mkConnection "ribble-router" "wlan0") ];
      };
    };
    ribble-bedroom-speaker = mkDevice "ribble-bedroom-speaker" {
      info = "Google Home Bedroom Speaker";
      deviceIcon = ./assets/google.svg;
      interfaces.wlan0 = {
        network = "burbage";
        type = "wifi";
        physicalConnections = [ (mkConnection "ribble-router" "wlan0") ];
      };
    };
    mccml44wmd6t = mkDevice "MCCML44WMD6T" {
      info = "Macbook Pro 2019 - Arup Workstation";
      deviceIcon = ./assets/apple.svg;
      interfaces.wlan0 = {
        network = "burbage";
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
        network = "internet";
        physicalConnections = [ (mkConnection "internet" "*") ];
      };
      interfaces.wlan0 = {
        network = "burbage";
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
  };
}
