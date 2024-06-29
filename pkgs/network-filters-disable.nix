{ pkgs, stdenv }:


if (!stdenv.isDarwin)
then throw "This script can only be run on darwin hosts"
else

  pkgs.writeShellApplication {
    name = "network-filters-disable";

    text = ''
      sudo launchctl unload /Library/LaunchDaemons/com.cisco.secureclient.vpnagentd.plist /Library/LaunchDaemons/com.cisco.secureclient.ciscod64.plist
    '';
  }
