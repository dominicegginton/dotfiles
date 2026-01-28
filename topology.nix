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
    ribble = {
      name = "LAN Ribble";
      cidrv4 = "192.168.1.0/24";
      cidrv6 = "fd00:1::/64";
      style = {
        primaryColor = "#702383ff";
        pattern = "solid";
      };
    };
    pixel-9 = {
      name = "Pixel 9 Hotspot";
      cidrv4 = "100.100.100.100/24";
      cidrv6 = "fd00:2::/64";
      style = {
        primaryColor = "#50c878ff";
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
    router = mkRouter "EE Router" {
      info = "EE Bright Box 2 Router";
      interfaceGroups = [
        [ "eth0" ]
        [
          "wlan0"
          "eth1"
          "eth2"
          "eth3"
          "eth4"
        ]
      ];
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
    switch = mkSwitch "Switch" {
      info = "Netgear GS108E Switch";
      interfaceGroups = [
        [
          "eth0"
          "eth1"
          "eth2"
          "eth3"
          "eth4"
          "eth5"
          "eth6"
          "eth7"
          "eth8"
          "eth9"
          "eth10"
          "eth11"
          "eth12"
          "eth13"
          "eth14"
          "eth15"
          "eth16"
        ]
      ];
      connections.eth0 = mkConnection "router" "eth1";
      connections.eth1 = mkConnection "security-camera" "eth0";
    };
    security-camera = mkDevice "Doorbell Camera" {
      info = "Reolink Doorbell Camera";
      deviceIcon = ./assets/reolink.svg;
      interfaces.eth0 = {
        network = "ribble";
        type = "ethernet";
        physicalConnections = [ (mkConnection "switch" "eth1") ];
      };
    };
    livingroom-google-tv = mkDevice "Living Room Google TV" {
      info = "Google Chromecast with Google TV 1080p";
      deviceIcon = ./assets/google.svg;
      interfaces.wlan0 = {
        network = "ribble";
        type = "wifi";
        physicalConnections = [ (mkConnection "router" "wlan0") ];
      };
    };
    livingroom-lamp-switch = mkDevice "Lamp" {
      info = "Sonoff Living Room Lamp Switch";
      interfaces.wlan0 = {
        network = "ribble";
        type = "wifi";
        physicalConnections = [ (mkConnection "router" "wlan0") ];
      };
    };
    kitchen-lamp-switch = mkDevice "Shelf Lamp" {
      info = "Sonoff Kitchen Lamp Switch";
      interfaces.wlan0 = {
        network = "ribble";
        type = "wifi";
        physicalConnections = [ (mkConnection "router" "wlan0") ];
      };
    };
    ribble-office-lamp-switch = mkDevice "Desk Lamp" {
      info = "Sonoff Office Lamp Switch";
      interfaces.wlan0 = {
        network = "ribble";
        type = "wifi";
        physicalConnections = [ (mkConnection "router" "wlan0") ];
      };
    };
    bedroom-lamps-switch = mkDevice "Bedside Lights" {
      info = "Sonoff Bedroom Lamps Switch";
      interfaces.wlan0 = {
        network = "ribble";
        type = "wifi";
        physicalConnections = [ (mkConnection "router" "wlan0") ];
      };
    };
    bedroom-speaker = mkDevice "Dom's Bedroom Speaker" {
      info = "Google Home Bedroom Speaker";
      deviceIcon = ./assets/google.svg;
      interfaces.wlan0 = {
        network = "ribble";
        type = "wifi";
        physicalConnections = [ (mkConnection "router" "wlan0") ];
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
        physicalConnections = [ (mkConnection "router" "wlan0") ];
      };
      interfaces.tailscale0 = {
        network = tailnet;
        type = "tailscale";
        icon = ./assets/tailscale.svg;
        virtual = true;
        addresses = [
          "pixel-9"
          "pixel-9.${tailnet}"
        ];
      };
    };
    steamdeck = mkDevice "steamdeck" {
      info = "Steam Deck";
      interfaces.wlan0 = {
        network = "ribble";
        type = "wifi";
        physicalConnections = [ (mkConnection "router" "wlan0") ];
      };
      interfaces.tailscale0 = {
        network = tailnet;
        type = "tailscale";
        icon = ./assets/tailscale.svg;
        virtual = true;
        addresses = [
          "steamdeck"
          "steamdeck.${tailnet}"
        ];
      };
    };
  };
}
