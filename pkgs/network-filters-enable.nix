## todo: convert to wrtier function

{ stdenv, writeShellApplication, ensure-user-is-root }:

if (!stdenv.isDarwin)
then throw "This script can only be run on darwin hosts"
else

  writeShellApplication {
    name = "network-filters-enable";
    runtimeInputs = [ ensure-user-is-root ];
    text = ''
      ensure-user-is-root
      launchctl load /Library/LaunchDaemons/com.cisco.secureclient.vpnagentd.plist /Library/LaunchDaemons/com.cisco.secureclient.ciscod64.plist
    '';
  }
