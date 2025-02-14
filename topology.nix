{ config, lib, ... }:

with config.lib.topology;

let
  mkUnifiAp = name:
    mkDevice name {
      info = "Unifi AP Light";
      interfaceGroups = [ [ "eth1" ] [ "wlan0" ] ];
      interfaces.wlan0 = {
        network = "quardon";
        type = "wifi";
      };
    };


  mkInterface = i: "${name}${toString i}";
  mkNunberedInterfaceGroup = name: n: map mkInterface (lib.range 0 n);
in

{
  nodes.internet = mkInternet {
    connections = mkConnection "quardon-router" "wan0";
  };

  nodes.quardon-router = mkRouter "Quardon Router" {
    info = "Unifi Security Gateway";
    interfaceGroups = [ [ "eth0" ] [ "wan0" ] ];
    interfaces.eth1 = {
      addresses = [ "192.168.1.1" ];
      network = "quardon";
    };
  };

  networks = {
    quardon = {
      name = "Local Network - Quardon";
      cidrv4 = "192.168.1.0/24";
      cidrv6 = "fd00:1::/64";
      style = {
        primaryColor = "#f0c674";
        pattern = "solid";
      };
    };
    tailscale = {
      name = "Tailscale - Burbage";
      cidrv4 = "100.100.100.100/24";
      cidrv6 = "fd00:2::/64";
      style = {
        primaryColor = "#70a5eb";
        pattern = "solid";
      };
    };
  };
  nodes = {
    quardon-switch-main = mkSwitch "Switch Main" {
      info = "Switch 48 Port";
      interfaceGroups = [ (mkNunberedInterfaceGroup "eth" 24) ];
      interfaces.eth0 = {
        network = "quardon";
      };
      connections.eth0 = mkConnection "quardon-router" "eth0";
      connections.eth1 = mkConnection "quardon-switch-secondary" "eth1";
      connections.eth2 = mkConnection "quardon-unifi-ap-downstairs" "eth1";
      connections.eth3 = mkConnection "quardon-unifi-ap-upstairs" "eth1";
      connections.eth9 = mkConnection "ip-camera" "eth1";
    };
    quardon-switch-secondary = mkSwitch "Switch Secondary" {
      info = "Switch 24 Port";
      interfaceGroups = [ (mkNunberedInterfaceGroup "eth" 16) ];
      connections.eth1 = mkConnection "quardon-unifi-ap-dom" "eth1";
    };
    quardon-unifi-ap-dom = mkUnifiAp "Unifi AP Dom";
    quardon-unifi-ap-downstairs = mkUnifiAp "Unifi AP Downstairs";
    quardon-unifi-ap-upstairs = mkUnifiAp "Unifi AP Upstairs";
    ip-camera = mkDevice "IP Camera" { interfaceGroups = [ [ "eth1" ] ]; };
    ## todo: tidy and finish
    darwin-laptop = mkDevice "Darwin Laptop" {
      info = "Macbook Pro 2019";
      interfaceGroups = [ [ "en0" ] ];
      interfaces.en0 = {
        network = "quardon";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-unifi-ap-dom" "wlan0")
          (mkConnection "quardon-unifi-ap-downstairs" "wlan0")
          (mkConnection "quardon-unifi-ap-upstairs" "wlan0")
        ];
      };
      interfaces.tailscale = {
        network = "tailscale";
        virtual = true;
      };
    };
    windows-10-laptop = mkDevice "Windows 10 Laptop" {
      info = "Dell XPS 15 7590";
      interfaceGroups = [ [ "wlan0" ] ];
      interfaces.wlan0 = {
        network = "quardon";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-unifi-ap-dom" "wlan0")
          (mkConnection "quardon-unifi-ap-downstairs" "wlan0")
          (mkConnection "quardon-unifi-ap-upstairs" "wlan0")
        ];
      };
      interfaces.tailscale = {
        network = "tailscale";
        virtual = true;
      };
    };
  };
}
