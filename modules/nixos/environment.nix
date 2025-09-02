{ config, pkgs, lib, ... }:

{
  config = {
    environment = {
      variables = {
        EDITOR = "nvim";
        SYSTEMD_EDITOR = "nvim";
        VISUAL = "nvim";
        PAGER = "less";
      };
      systemPackages = with pkgs; [
        (lib.hiPrio uutils-coreutils-noprefix) # Use uutils-coreutils
        (lib.hiPrio uutils-findutils) # Use uutils-findutils
        (lib.hiPrio uutils-diffutils) # Use uutils-diffutils
        hwinfo # Hardware information tool 
        usbutils # USB device information
        nvme-cli # NVMe device management
        smartmontools # Disk health monitoring
        power-profiles-daemon # Power management daemon
        twm # Twmux window manager
        twx # Twmux server exterminator 
        neovim # Editor
        fzf # Fuzzy finder
        ripgrep # Fast text search tool
        ripgrep-all # Ripgrep with additional file support
        less # Pager 
        tree # Directory tree viewer
        dust # Disk usage analyzer
        fd # Fast file finder
        file # File type identification 
        (if stdenv.isLinux then trashy else darwin.trash) # Use trashy on Linux, darwin.trash on Darwin 
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
        bottom # System resource monitor
        htop-vim # Interactive process viewer
        status # System status monitoring
        openssl # Secure communications
        openssh # Secure shell client
        curl # Data transfer tool
        wget # Network downloader
        dnsutils # DNS lookup tools
        git # Version control system
        git-lfs # Git Large File Storage
        pinentry # PIN entry program for GnuPG
        pinentry-curses # Curses-based PIN entry program
        gnupg # GNU Privacy Guard
      ];
    };
  };
}

