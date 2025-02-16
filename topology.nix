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
        physicalConnections = (filter ({ node }: node != name) (connectionsToAccessPoints "wlan0"));
      };
    };
  mkInterface = name: i: "${name}${toString i}";
  mkNunberedInterfaceGroup = name: n: (map (i: mkInterface name i) (lib.range 0 n));
  connectionsToAccessPoints = interface: [
    (mkConnection "quardon-unifi-ap-dom" interface)
    (mkConnection "quardon-unifi-ap-downstairs" interface)
    (mkConnection "quardon-unifi-ap-upstairs" interface)
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

  nodes.internet = mkInternet {
    connections = mkConnection "quardon-router" "wan0";
  };

  nodes.quardon-router = mkRouter "Quardon Router" {
    info = "Unifi Security Gateway";
    interfaceGroups = [ [ "wan0" ] [ "eth0" ] ];
    interfaces.eth0 = {
      addresses = [ "192.168.1.1" ];
      network = "quardon";
    };
  };

  nodes.quardon-switch-main = mkSwitch "Switch Main" {
    info = "Switch 48 Port";
    interfaceGroups = [ (mkNunberedInterfaceGroup "eth" 24) ];
    connections.eth0 = mkConnection "quardon-router" "eth0";
    connections.eth1 = mkConnection "quardon-switch-secondary" "eth0";
    connections.eth2 = mkConnection "quardon-unifi-ap-downstairs" "eth0";
    connections.eth9 = mkConnection "ip-camera" "eth0";
  };
  nodes.quardon-switch-secondary = mkSwitch "Switch Secondary" {
    info = "Switch 24 Port";
    interfaceGroups = [ (mkNunberedInterfaceGroup "eth" 16) ];
    connections.eth1 = mkConnection "quardon-unifi-ap-dom" "eth0";
  };

  nodes.quardon-unifi-ap-dom = mkUnifiAp "Unifi AP Dom";
  nodes.quardon-unifi-ap-downstairs = mkUnifiAp "Unifi AP Downstairs";
  nodes.quardon-unifi-ap-upstairs = mkUnifiAp "Unifi AP Upstairs";

  nodes.ip-camera = mkDevice "IP Camera" { interfaceGroups = [ [ "eth0" ] ]; };

  nodes.darwin-laptop = mkDevice "Darwin Laptop" {
    info = "Macbook Pro 2019";
    interfaceGroups = [ [ "wlan0" ] ];
    interfaces.wlan0 = {
      network = "quardon";
      type = "wifi";
      physicalConnections = connectionsToAccessPoints "wlan0";
    };
    interfaces.tailscale = {
      network = "tailscale";
      virtual = true;
    };
  };
}
