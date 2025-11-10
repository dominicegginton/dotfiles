{ config, lib, pkgs, ... }:

with lib;

{
  options.users.home = mkOption {
    type = types.attrsOf (types.submodule {
      options = {
        directory = mkOption {
          type = types.string;
          description = "The directory where user home files and directories will be set up.";
        };
        files = mkOption {
          type = types.attrsOf (types.submodule {
            options = {
              source = mkOption {
                type = types.path;
                description = "The source file or directory to be copied to the user's home directory.";
              };
              recursive = mkOption {
                type = types.bool;
                default = false;
                description = "Whether to copy directories recursively.";
              };
            };
          });
          default = { };
          description = "Files to be added to user home directories.";
        };
      };
    });
    default = { };
    description = "Files and directories to be set up in user home directories.";
  };

  config = {
    users.home.dom = {
      files = {
        "hello.txt".source = pkgs.writeText "hello.txt" "Hello, dom!";
      };
    };

    ## TODO: implement setup logic
    system.userActivationScripts = lib.mapAttrs
      (username: userConfig: ''
        echo "Setting up home directory for user: ${username}"
      '')
      config.users.home;
  };
}

