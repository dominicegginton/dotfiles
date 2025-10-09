{ config, ... }: {
  options.display.steamos.enable.default = false;

  config = lib.mkIf config.display.steamos.enable { };
}
