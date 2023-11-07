{pkgs, ...}:
pkgs.writeShellApplication {
  name = "network-filters-enable";

  text = ''
    sudo launchctl load /Library/LaunchDaemons/com.cisco.secureclient.vpnagentd.plist /Library/LaunchDaemons/com.cisco.secureclient.ciscod64.plist
  '';
}
