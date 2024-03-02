{
  inputs,
  outputs,
  hostname,
  username,
  platform,
  stateVersion,
  pkgs,
  ...
}: {
  imports = [
    ../modules/darwin.nix # NixDarwin system and environment configuration
    ../modules/homebrew.nix # Homebrew managed packages
    ../modules/system.nix # Nix system and environment configuration
    ../modules/networking.nix # Networking, firewall and tailscale configuration
    ../modules/console.nix # Console environment
    ./${hostname} # Host specific configuration
  ];

  modules.system.platform = platform;
  modules.system.allowUnfree = true;
  modules.system.stateVersion = stateVersion;

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      ibm-plex
    ];
  };
}
