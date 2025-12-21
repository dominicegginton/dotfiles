{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268087
    vlock
    # # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268136
    opencryptoki

    run0-sudo-shim # Provide sudo functionality on systems without sudo

    (lib.hiPrio uutils-coreutils-noprefix) # Use uutils-coreutils
    (lib.hiPrio uutils-findutils) # Use uutils-findutils
    (lib.hiPrio uutils-diffutils) # Use uutils-diffutils
    killall # Kill processes by name
    hwinfo # Hardware information tool
    usbutils # USB device information
    nvme-cli # NVMe device management
    smartmontools # Disk health monitoring
    twm # Twmux window manager
    twx # Twmux server exterminator
    neovim # Editor
    fzf # Fuzzy finder
    ripgrep # Fast text search tool
    ripgrep-all # Ripgrep with additional file support
    less # Pager
    tree # Directory tree viewer
    sysz # Fzf ui for systemd
    dust # Disk usage analyzer
    fd # Fast file finder
    file # File type identification
    trashy # Command-line trash utility
    dua # Disk usage analyzer
    gum # Command-line UI tooling
    jq # JSON processor
    fx # Interactive JSON viewer
    nix-output-monitor # Monitor Nix build outputs
    nixpkgs-fmt # Nix expression formatter
    cachix # Cachix binary cache client
    deadnix # Dead code detector for Nix
    nix-diff # Nix expression differ
    nix-tree # Nix dependency tree visualizer
    nix-health # Nix system health checker
    htop-vim # Interactive process viewer
    openssl # Secure communications
    openssh # Secure shell client
    curl # Data transfer tool
    wget # Network downloader
    dnsutils # DNS lookup tools
    git # Version control system
    git-lfs # Git Large File Storage
    pinentry-curses # Curses-based PIN entry program
    gnupg # GNU Privacy Guard
  ];
}
