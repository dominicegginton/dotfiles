{ pkgs, ... }:

{
  config = {
    environment = {
      variables = {
        EDITOR = "vim";
        SYSTEMD_EDITOR = "vim";
        VISUAL = "vim";
        PAGER = "less";
      };
      systemPackages = with pkgs; [
        cachix
        file
        gitMinimal
        vim
        killall
        hwinfo
        unzip
        wget
        htop-vim
        bottom
        usbutils
        nvme-cli
        smartmontools
        fzf
        ripgrep
        fd
        jq
        less
        bat
        git
        git-lfs
        pinentry
        pinentry-curses
        host-status
      ];
    };
  };
}
