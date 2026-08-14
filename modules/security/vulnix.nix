{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.security.vulnix = {
    enable = lib.mkEnableOption "vulnix system scanning" // {
      default = true;
    };

    scanOnActivation = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to scan the system for vulnerabilities on activation.";
    };

    whitelist = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to vulnix whitelist TOML file.";
    };
  };

  config = lib.mkIf config.security.vulnix.enable {
    environment.systemPackages = [ pkgs.vulnix ];

    system.activationScripts.vulnix = lib.mkIf config.security.vulnix.scanOnActivation {
      supportsDryActivation = true;
      text = ''
        ${lib.getExe pkgs.gum} log --level info "Scanning system derivation $systemConfig with vulnix..."
        # We run vulnix on $systemConfig, but do not block activation if vulnerabilities are found or network/fetch fails.
        ${lib.getExe pkgs.vulnix} ${lib.optionalString (config.security.vulnix.whitelist != null) "-w ${config.security.vulnix.whitelist}"} "$systemConfig" || {
          ${lib.getExe pkgs.gum} log --level warn "vulnix found vulnerabilities or failed to run. Check the log above."
        }
      '';
    };
  };
}
