{pkgs, ...}:
pkgs.writeShellApplication {
  name = "network-filters-disable";

  text = ''
    sudo launchctl unload /Library/LaunchDaemons/com.cisco.secureclient.vpnagentd.plist /Library/LaunchDaemons/com.cisco.secureclient.ciscod64.plist
  '';
}
