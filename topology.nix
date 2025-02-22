{ config, lib, ... }:

with config.lib.topology;
with lib;

let
  mkUnifiAp = name:
    mkDevice name {
      info = "Unifi AP Light";
      interfaceGroups = [ [ "eth0" ] [ "wlan0" ] ];
      interfaces.wlan0 = {
        network = "quardon";
        type = "wifi";
        physicalConnections = (filter ({ node, ... }: node != name) (connectionsToAccessPoints));
      };
    };
  mkInterface = name: i: "${name}${toString i}";
  mkNunberedInterfaceGroup = name: n: (map (i: mkInterface name i) (lib.range 0 n));
  connectionsToAccessPoints = [
    (mkConnection "quardon-unifi-ap-dom" "wlan0")
    (mkConnection "quardon-unifi-ap-downstairs" "wlan0")
    (mkConnection "quardon-unifi-ap-upstairs" "wlan0")
  ];
in

{
  networks.tailscale = {
    name = "Tailscale - Burbage";
    cidrv4 = "100.100.100.100/24";
    cidrv6 = "fd00:2::/64";
    style = {
      primaryColor = "#70a5eb";
      secondaryColor = "#0000000";
      pattern = "dotted";
    };
  };
  networks.quardon = {
    name = "Local Network - Quardon";
    cidrv4 = "192.168.1.0/24";
    cidrv6 = "fd00:1::/64";
    style = {
      primaryColor = "#f0c674";
      pattern = "solid";
    };
  };

  nodes.internet = mkInternet {};

  nodes.quardon-router = mkRouter "Quardon Router" {
    info = "Unifi Security Gateway";
    interfaces.eth0 = {
      physicalConnections = [ (mkConnection "internet" "*" ) ];
    };
    interfaces.eth0 = {
      addresses = [ "192.168.1.1" ];
      network = "quardon";
    };
  };
  nodes.quardon-switch-main = mkSwitch "Quardon Switch Main" {
    info = "Switch 48 Port";
    interfaceGroups = [ (mkNunberedInterfaceGroup "eth" 24) ];
    connections.eth0 = mkConnection "quardon-router" "eth0";
    connections.eth1 = mkConnection "quardon-switch-secondary" "eth0";
    connections.eth2 = mkConnection "quardon-unifi-ap-downstairs" "eth0";
    connections.eth3 = mkConnection "quardon-unifi-ap-upstairs" "eth0";
    connections.eth4 = mkConnection "quardon-reolink-ip-camera" "eth0";
  };
  nodes.quardon-switch-secondary = mkSwitch "Quardon Switch Secondary" {
    info = "Switch 24 Port";
    interfaceGroups = [ (mkNunberedInterfaceGroup "eth" 16) ];
    connections.eth1 = mkConnection "quardon-unifi-ap-dom" "eth0";
  };

  nodes.quardon-unifi-ap-dom = mkUnifiAp "Quardon Unifi AP Dom";
  nodes.quardon-unifi-ap-downstairs = mkUnifiAp "Quardon Unifi AP Downstairs";
  nodes.quardon-unifi-ap-upstairs = mkUnifiAp "Quardon Unifi AP Upstairs";

  nodes.quardon-reolink-ip-camera = mkDevice "Quardon Reolink IP Camera" {
    interfaces.eth0 = { };
  };

  nodes.darwin-laptop = mkDevice "Darwin Laptop" {
    info = "Macbook Pro 2019";
    interfaces.wlan0 = {
      network = "quardon";
      type = "wifi";
      physicalConnections = connectionsToAccessPoints;
    };
    interfaces.tailscale = {
      network = "tailscale";
      virtual = true;
    };
  };

  nodes.pixel-9 = mkDevice "Pixel 9" {
    info = "Google Pixel 9";
    interfaces."5G-radio" = {
      type = "wifi";
      physicalConnections = [(mkConnection "internet" "*" )];
    };
    interfaces.wifi = {
      network = "quardon";
      type = "wifi";
      physicalConnections = connectionsToAccessPoints;
    };
    interfaces.tailscale = {
      network = "tailscale";
      virtual = true;
    };
  };
}
