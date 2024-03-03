{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  inherit (pkgs.stdenv) isLinux;

  cfg = config.modules.console;
in {
  config = {
    home.sessionVariables.EDITOR = "nvim";
    home.sessionVariables.SYSTEMD_EDITOR = "nvim";
    home.sessionVariables.VISUAL = "nvim";

    programs = {
      bash.enable = true;
      git.enable = true;
      info.enable = true;
      hstr.enable = true;
      gpg.enable = true;

      zsh = {
        enable = true;
        enableCompletion = true;
        enableAutosuggestions = true;
        autocd = true;
        defaultKeymap = "viins";
        oh-my-zsh.enable = true;
        oh-my-zsh.theme = "eastwood";
      };

      neovim = {
        enable = true;
        package = pkgs.neovim-nightly;
        viAlias = true;
        vimAlias = true;
        extraPackages = with pkgs; [
          nodejs-slim
          gcc
          zig
          ripgrep
          tree-sitter
          rnix-lsp
          terraform-lsp
          lua-language-server
          nodePackages.vim-language-server
          nodePackages.bash-language-server
          nodePackages.yaml-language-server
          nodePackages.dockerfile-language-server-nodejs
          nodePackages.typescript
          nodePackages.typescript-language-server
          nodePackages.vscode-langservers-extracted
          nodePackages."@angular/cli"
          nodePackages.pyright
          prettierd
          eslint_d
          rust-analyzer
          stylua
        ];
      };

      gh = {
        enable = true;
        extensions = with pkgs; [
          gh-markdown-preview # Markdown preview in browser
        ];
        settings = {
          editor = "nvim";
          git_protocol = "https";
          prompt = "enabled";
        };
      };

      lf = {
        enable = true;
        commands = {
          dragon-out = ''%${pkgs.xdragon}/bin/xdragon -a -x "$fx"'';
          editor-open = ''$$EDITOR $f'';
          mkdir = ''
            ''${{
              printf "Directory Name: "
              read DIR
              mkdir $DIR
            }}
          '';
        };

        keybindings = {
          "\\\"" = "";
          o = "";
          c = "mkdir";
          "." = "set hidden!";
          "`" = "mark-load";
          "\\'" = "mark-load";
          "<enter>" = "open";
          do = "dragon-out";
          "g~" = "cd";
          gh = "cd";
          "g/" = "/";
          ee = "editor-open";
          V = ''$${pkgs.bat}/bin/bat --paging=always --theme=gruvbox "$f"'';
        };

        settings = {
          preview = true;
          hidden = true;
          drawbox = true;
          ignorecase = true;
        };

        extraConfig = let
          previewer = pkgs.writeShellScriptBin "pv.sh" ''
            file=$1
            w=$2
            h=$3
            x=$4
            y=$5
            if [[ "$( ${pkgs.file}/bin/file -Lb --mime-type "$file")" =~ ^image ]]; then
                ${pkgs.kitty}/bin/kitty +kitten icat --silent --stdin no --transfer-mode file --place "''${w}x''${h}@''${x}x''${y}" "$file" < /dev/null > /dev/tty
                exit 1
            fi
            ${pkgs.pistol}/bin/pistol "$file"
          '';

          cleaner = pkgs.writeShellScriptBin "clean.sh" ''
            ${pkgs.kitty}/bin/kitty +kitten icat --clear --stdin no --silent --transfer-mode file < /dev/null > /dev/tty
          '';
        in ''
          set cleaner ${cleaner}/bin/clean.sh
          set previewer ${previewer}/bin/pv.sh
        '';
      };
    };

    services.gpg-agent = mkIf isLinux {
      enable = true;
      enableSshSupport = true;
      enableZshIntegration = true;
    };

    home.packages = with pkgs; [
      git # Srouce control
      git-lfs # Git large file storage
      git-sync
      gnupg # GPG tool suite for encryption and signing
      tmux # Terminal multiplexer
      twm # Tmux window manager
      twx
      rebuild-home
    ];
  };
}
