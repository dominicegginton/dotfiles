{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "network-filters-enable";
      text = ''
        echo "Enabling network filters..."
        sudo launchctl load /Library/LaunchDaemons/com.cisco.secureclient.vpnagentd.plist /Library/LaunchDaemons/com.cisco.secureclient.ciscod64.plist
      '';
    })
    (pkgs.writeShellApplication {
      name = "network-filters-disable";
      text = ''
        echo "Disabling network filters..."
        sudo launchctl unload /Library/LaunchDaemons/com.cisco.secureclient.vpnagentd.plist /Library/LaunchDaemons/com.cisco.secureclient.ciscod64.plist
      '';
    })
  ];
}
