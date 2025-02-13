{ config, ... }:

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

  mkNunberedInterfaceGroup = name: n:
    [ "${name}${toString n}" ];
in

{
  nodes.internet = mkInternet {
    connections = mkConnection "quardon-router" "wan1";
  };

  nodes.quardon-router = mkRouter "Quardon Router" {
    info = "Unifi Security Gateway";
    interfaceGroups = [
      [ "eth1" ]
      [ "wan1" "wan2" ]
    ];
    interfaces.eth1 = {
      addresses = [ "192.168.1.1" ];
      network = "quardon";
    };
  };

  networks.quardon = {
    name = "Local Network - Quardon";
    style = {
      primaryColor = "#f0c674";
      pattern = "solid";
    };
  };
  networks.tailscale = {
    name = "Tailscale - Burbage";
    style = {
      primaryColor = "#70a5eb";
      pattern = "solid";
    };
  };
  nodes.quardon-switch-main = mkSwitch "Switch Main" {
    info = "Switch 48 Port";
    interfaceGroups = [ (mkNunberedInterfaceGroup "eth" 48) ];
    connections.eth1 = mkConnection "quardon-router" "eth1";
    connections.eth6 = mkConnection "quardon-unifi-ap-dom" "eth1";
    connections.eth7 = mkConnection "quardon-unifi-ap-downstairs" "eth1";
    connections.eth8 = mkConnection "quardon-unifi-ap-upstairs" "eth1";

    connections.eth9 = mkConnection "ip-camera" "eth1";
  };
  nodes.quardon-unifi-ap-dom = mkUnifiAp "Unifi AP Dom";
  nodes.quardon-unifi-ap-downstairs = mkUnifiAp "Unifi AP Downstairs";
  nodes.quardon-unifi-ap-upstairs = mkUnifiAp "Unifi AP Upstairs";
  nodes.ip-camera = mkDevice "IP Camera" {
    info = "IP based security cam";
    interfaceGroups = [ [ "eth1" ] ];
  };
}
