with import <nixpkgs> {};

assert (stdenv.buildPlatform.isDarwin == false) -> throw "this package builds only on darwin";

let
  network-filters-enable = pkgs.writeShellApplication {
    name = "network-filters-enable";
    text = ''
      echo "Enabling network filters..."
      sudo launchctl load /Library/LaunchDaemons/com.cisco.secureclient.vpnagentd.plist /Library/LaunchDaemons/com.cisco.secureclient.ciscod64.plist
    '';
  };

  network-filters-disable = pkgs.writeShellApplication {
    name = "network-filters-disable";
    text = ''
      echo "Disabling network filters..."
      sudo launchctl unload /Library/LaunchDaemons/com.cisco.secureclient.vpnagentd.plist /Library/LaunchDaemons/com.cisco.secureclient.ciscod64.plist
    '';
  };
in

stdenv.mkDerivation rec {
  name = "network-filters";

  buildInputs = [
    network-filters-enable
    network-filters-disable
  ];

  meta = {
    description = "Scripts to enable and disable network filters";
    platforms = with platforms; darwin;
  };
}
