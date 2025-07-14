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
      connections.eth1 = mkConnection "quardon-switch-secondary" "eth0";
      connections.eth2 = mkConnection "quardon-ap-downstairs" "eth0";
      connections.eth3 = mkConnection "quardon-ap-upstairs" "eth0";
      connections.eth4 = mkConnection "quardon-front-security-camera" "eth0";
      connections.eth5 = mkConnection "quardon-back-security-camera" "eth0";
    };
    quardon-switch-secondary = mkSwitch "quardon-switch-secondary" {
      info = "Netgear Switch 16 Port";
      interfaceGroups = [ [ "eth0" "eth1" "eth2" ] ];
      connections.eth1 = mkConnection "quardon-ap-dom" "eth0";
    };
    quardon-ap-dom = mkDevice "quardon-ap-dom" {
      info = "Unifi AP Light";
      interfaceGroups = [ [ "eth0" "wlan0" ] ];
      interfaces.wlan0 = {
        network = "burbage";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
        ];
      };
    };
    quardon-ap-downstairs = mkDevice "quardon-ap-downstairs" {
      info = "Unifi AP Light";
      interfaceGroups = [ [ "eth0" "wlan0" ] ];
      interfaces.wlan0 = {
        network = "burbage";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-dom" "wlan0")
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
          (mkConnection "quardon-ap-dom" "wlan0")
          (mkConnection "quardon-ap-downstairs" "wlan0")
        ];
      };
    };
    quardon-front-center-security-camera = mkDevice "quardon-front-center-security-camera" {
      info = "Reolink PTZ Security Camera";
      interfaces.wlan0 = {
        network = "burbage";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-dom" "wlan0")
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
        ];
      };
    };
    quardon-front-security-camera = mkDevice "quardon-front-security-camera" {
      info = "Reolink Security Camera";
      interfaces.eth0 = { };
    };
    quardon-back-security-camera = mkDevice "quardon-back-security-camera" {
      info = "Reolink Security Camera";
      interfaces.eth0 = { };
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
    };
    ribble-switch = mkSwitch "ribble-switch" {
      info = "Switch";
      connections.eth0 = mkConnection "ribble-router" "eth1";
      connections.eth1 = mkConnection "ribble-ap" "eth0";
      connections.eth2 = mkConnection "ribble-security-camera" "eth0";
    };
    ribble-ap = mkDevice "ribble-ap" {
      info = "Unifi AP Light";
      interfaceGroups = [ [ "eth0" "wlan0" ] ];
      interfaces.wlan0 = {
        network = "burbage";
        type = "wifi";
      };
    };
    ribble-security-camera = mkDevice "ribble-security-camera" {
      info = "Security Camera";
      interfaces.eth0 = { };
    };
    mccml44wmd6t = mkDevice "MCCML44WMD6T" {
      info = "Macbook Pro 2019 - Arup Workstation";
      deviceIcon = ./assets/apple.svg;
      interfaces.wlan0 = {
        network = "burbage";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-ap-dom" "wlan0")
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
          (mkConnection "ribble-ap" "wlan0")

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
          (mkConnection "quardon-ap-dom" "wlan0")
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
          (mkConnection "ribble-ap" "wlan0")
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
