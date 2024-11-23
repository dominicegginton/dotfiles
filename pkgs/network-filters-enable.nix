{ stdenv, writeShellApplication }:

if (!stdenv.isDarwin)
then throw "This script can only be run on darwin hosts"
else

  writeShellApplication {
    name = "network-filters-enable";
    text = '"sudo launchctl load /Library/LaunchDaemons/com.cisco.secureclient.vpnagentd.plist /Library/LaunchDaemons/com.cisco.secureclient.ciscod64.plist";
  }
