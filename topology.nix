{ config, lib, ... }:

with config.lib.topology;
with lib;

let
  mkInterface = name: i: "${name}${toString i}";
  mkNunberedInterfaceGroup = name: n: (map (i: mkInterface name i) (lib.range 0 n));
in

{
  nodes.internet = mkInternet { };
  networks.internet = {
    name = "Internet";
    style = {
      primaryColor = "#cc241d";
      secondaryColor = "transparent";
      pattern = "dotted";
    };
  };
  networks.tailscale = {
    name = "burbage";
    cidrv4 = "100.100.100.100/24";
    cidrv6 = "fd00:2::/64";
    style = {
      primaryColor = "#70a5eb";
      secondaryColor = "transparent";
      pattern = "dashed";
    };
  };
  networks.quardon = {
    name = "quardon";
    cidrv4 = "192.168.1.0/24";
    cidrv6 = "fd00:1::/64";
    style = {
      primaryColor = "#4e9a06";
      pattern = "solid";
    };
  };
  networks.ribble = {
    name = "ribble";
    cidrv4 = "192.168.1.0/24";
    cidrv6 = "fd00:1::/64";
    style = {
      primaryColor = "#f000aa";
      pattern = "solid";
    };
  };

  nodes.quardon-router = mkRouter "secure gateway" {
    info = "Unifi Security Gateway";
    interfaceGroups = [ [ "eth0" ] [ "eth1" ] ];
    interfaces.eth0 = {
      network = "internet";
      type = "fiber-duplex";
      physicalConnections = [ (mkConnection "internet" "*") ];
    };
    interfaces.eth1 = {
      network = "quardon";
      addresses = [ "192.168.1.1" ];
    };
  };
  nodes.quardon-switch-main = mkSwitch "network cabinet switch" {
    info = "Cisco Switch 24 Port - Network Cabinet";
    interfaceGroups = [ (mkNunberedInterfaceGroup "eth" 24) ];
    connections.eth0 = mkConnection "quardon-router" "eth1";
    connections.eth1 = mkConnection "quardon-switch-secondary" "eth0";
    connections.eth2 = mkConnection "quardon-unifi-ap-downstairs" "eth0";
    connections.eth3 = mkConnection "quardon-unifi-ap-upstairs" "eth0";
    connections.eth4 = mkConnection "quardon-front-security-camera" "eth0";
    connections.eth5 = mkConnection "quardon-back-security-camera" "eth0";
  };
  nodes.quardon-switch-secondary = mkSwitch "doms's room switch" {
    info = "Netgear Switch 16 Port - Dom's Room";
    interfaceGroups = [ (mkNunberedInterfaceGroup "eth" 16) ];
    connections.eth1 = mkConnection "quardon-unifi-ap-dom" "eth0";
  };
  nodes.quardon-unifi-ap-dom = mkDevice "dom's room wireless access point" {
    info = "Unifi AP Light - Doms's Room";
    interfaceGroups = [ [ "eth0" "wlan0" ] ];
    interfaces.wlan0 = {
      network = "quardon";
      type = "wifi";
      physicalConnections = [

      ];
    };
  };
  nodes.quardon-unifi-ap-downstairs = mkDevice "downstairs wireless access point" {
    info = "Unifi AP Light - Downstairs";
    interfaceGroups = [ [ "eth0" "wlan0" ] ];
    interfaces.wlan0 = {
      network = "quardon";
      type = "wifi";
      physicalConnections = [
        (mkConnection "quardon-unifi-ap-dom" "wlan0")
        (mkConnection "quardon-unifi-ap-upstairs" "wlan0")
      ];
    };
  };
  nodes.quardon-unifi-ap-upstairs = mkDevice "upstairs wireless access point" {
    info = "Unifi AP Light - Upstairs";
    interfaceGroups = [ [ "eth0" "wlan0" ] ];
    interfaces.wlan0 = {
      network = "quardon";
      type = "wifi";
      physicalConnections = [
        (mkConnection "quardon-unifi-ap-dom" "wlan0")
        (mkConnection "quardon-unifi-ap-downstairs" "wlan0")
      ];
    };
  };
  nodes.quardon-front-security-camera = mkDevice "front drive security camera" {
    info = "Reolink Security Camera - Front";
    interfaces.eth0 = { };
  };
  nodes.quardon-back-security-camera = mkDevice "back drive security camera" {
    info = "Reolink Security Camera - Back";
    interfaces.eth0 = { };
  };

  nodes.ribble-router = mkRouter "secure gateway" {
    info = "Unifi Security Gateway";
    interfaceGroups = [ [ "eth0" ] [ "eth1" ] ];
    interfaces.eth0 = {
      network = "internet";
      type = "fiber-duplex";
      physicalConnections = [ (mkConnection "internet" "*") ];
    };
    interfaces.eth1 = {
      network = "ribble";
      addresses = [ "192.168.1.1" ];
    };
  };
  nodes.ribble-switch-main = mkSwitch "network room switch" {
    info = "Netgear Switch 16 Port";
    interfaceGroups = [ (mkNunberedInterfaceGroup "eth" 16) ];
    connections.eth0 = mkConnection "ribble-router" "eth1";
    connections.eth1 = mkConnection "ribble-unifi-ap" "eth0";
    connections.eth2 = mkConnection "ribble-front-security-camera" "eth0";
  };
  nodes.ribble-unifi-ap = mkDevice "network room wireless access point" {
    info = "Unifi AP Light - Network Room";
    interfaceGroups = [ [ "eth0" ] [ "wlan0" ] ];
    interfaces.wlan0 = {
      network = "ribble";
      type = "wifi";
    };
  };
  nodes.ribble-front-security-camera = mkDevice "front drive security camera" {
    info = "Security Camera - Front";
    interfaces.eth0 = { };
  };

  nodes.darwin-laptop = mkDevice "MCCML44WMD6T" {
    info = "Macbook Pro 2019 - Workstation";
    icon = ./assets/apple.svg;
    interfaceGroups = [ [ "wlan0-quardon" ] [ "wlan0-ribble" ] [ "tailscale" ] ];
    interfaces.wlan0-quardon = {
      network = "quardon";
      type = "wifi";
      physicalConnections = [
        (mkConnection "quardon-unifi-ap-dom" "wlan0")
        (mkConnection "quardon-unifi-ap-downstairs" "wlan0")
        (mkConnection "quardon-unifi-ap-upstairs" "wlan0")
      ];
    };
    interfaces.wlan0-ribble = {
      network = "ribble";
      type = "wifi";
      physicalConnections = [
        (mkConnection "ribble-unifi-ap" "wlan0")
      ];
    };
    interfaces.tailscale = {
      network = "tailscale";
      type = "tailscale";
      icon = ./assets/tailscale.svg;
      virtual = true;
    };
  };

  nodes.pixel-9 = mkDevice "pixel-9" {
    info = "Google Pixel 9 - Smartphone";
    icon = ./assets/google.svg;
    interfaceGroups = [ [ "5g-radio" ] [ "wlan0-quardon" ] [ "wlan0-ribble" ] [ "tailscale" ] ];
    interfaces."5g-radio" = {
      network = "internet";
      physicalConnections = [
        (mkConnection "internet" "*")
      ];
    };
    interfaces.wlan0-quardon = {
      network = "quardon";
      type = "wifi";
      physicalConnections = [
        (mkConnection "quardon-unifi-ap-dom" "wlan0")
        (mkConnection "quardon-unifi-ap-downstairs" "wlan0")
        (mkConnection "quardon-unifi-ap-upstairs" "wlan0")
      ];
    };
    interfaces.wlan0-ribble = {
      network = "ribble";
      type = "wifi";
      physicalConnections = [
        (mkConnection "ribble-unifi-ap" "wlan0")
      ];
    };
    interfaces.tailscale = {
      network = "tailscale";
      type = "tailscale";
      icon = ./assets/tailscale.svg;
      virtual = true;
    };
  };
}
