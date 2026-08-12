{
  self,
  config,
  lib,
  ...
}:

{
  home-manager = {
    useGlobalPkgs = lib.mkForce true; # Always use global pkgs for Home Manager
    backupFileExtension = lib.mkForce "backup"; # Set backup extension for Home Manager
    sharedModules = [
      self.inputs.base16.homeManagerModule # Base16 theming for Home Manager
      {
        scheme = config.scheme;
        home = {
          stateVersion = lib.mkForce "25.11"; # Pin Home Manager state version
          enableNixpkgsReleaseCheck = lib.mkForce false; # Disable release check
        };
        programs = {
          bash.enable = lib.mkForce true; # Always enable bash
          info.enable = lib.mkForce true; # Always enable info
          hstr.enable = lib.mkForce true; # Always enable hstr
          gpg = {
            enable = lib.mkDefault true;
            settings = {
              personal-cipher-preferences = "AES256 AES192 AES";
              personal-digest-preferences = "SHA512 SHA384 SHA256";
              personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
              default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
              cert-digest-algo = "SHA512";
              s2k-digest-algo = "SHA512";
              s2k-cipher-algo = "AES256";
              charset = "utf-8";
              no-comments = true;
              no-emit-version = true;
              no-greeting = true;
              keyid-format = "0xlong";
              list-options = "show-uid-validity";
              verify-options = "show-uid-validity";
              with-fingerprint = true;
              require-cross-certification = true;
              require-secmem = true;
              no-symkey-cache = true;
              armor = true;
              use-agent = true;
              throw-keyids = true;
            };
          };
        };
      }
    ];
  };
}
