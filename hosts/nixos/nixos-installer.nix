{ lib, pkgs, hostname, tailnet, ... }:

with lib;

{
  environment.systemPackages = with pkgs; [
    tailscale
    status
    ## TODO: script to bootstrap nixos
    ## 1. connect to the network
    ## 2. authenticate with bitwarden to get the tailscale auth key
    ## 3. select the target configuration from the github flake (github:dominicegginton/dotfiles)
    ## 4. build and the target configuration
    (writeShellScriptBin "bootstrap" ''
      export PATH=${lib.makeBinPath [ ensure-user-is-root coreutils git busybox nix fzf jq gum bws ]}
      set -efu -o pipefail
      ensure-user-is-root
      temp=$(mktemp -d)
      cleanup() {
        rm -rf "$temp"
      }
      trap cleanup EXIT
      # 1. connect to the network
      # 5. authenticate with bitwarden to get the tailscale auth key
      # 3. select the target configuration from the github flake (github:dominicegginton/dotfiles)
      # 5. build and the target configuration 
    '')
  ];
  networking = { hostName = hostname; };
  topology.self = {
    hardware.info = "ad-doc usb flash drive";
    interfaces.tailscale0 = {
      network = tailnet;
      type = "tailscale";
      icon = ../../assets/tailscale.svg;
      virtual = true;
    };
  };
}
