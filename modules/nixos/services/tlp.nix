{ config, lib, ... }:

let
  batteryThresholdType = lib.types.submodule {
    options = {
      enable = lib.mkEnableOption "TLP Battery Charge Thresholds";
      start = lib.mkOption {
        type = lib.mkOptionType {
          name = "int";
          check = start: lib.isInt start && start >= 0 && start <= 100;
        };
        description = "Battery charge threshold start value (in %).";
        default = 75;
      };
      stop = lib.mkOption {
        type = lib.mkOptionType {
          name = "int";
          check = stop: lib.isInt stop && stop >= 0 && stop <= 100 && stop > config.services.tlp.batteryThreshold.start;
        };
        description = "Battery charge threshold stop value (in %).";
        default = 80;
      };
    };
  };
in

{
  options.services.tlp.batteryThreshold = lib.mkOption {
    type = batteryThresholdType;
    description = "TLP Battery Charge Thresholds configuration.";
    default = {
      enable = false;
      start = 75;
      stop = 80;
    };
  };

  config.services = lib.mkIf config.services.tlp.enable {
    power-profiles-daemon.enable = lib.mkForce false;
    tlp.settings = lib.mkIf config.services.xserver.desktopManager.gnome.enable {
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 1;
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 1;
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "balanced";
      START_CHARGE_THRESH_BAT0 = lib.mkIf config.services.tlp.batteryThreshold.enable (builtins.toString config.services.tlp.batteryThreshold.start);
      STOP_CHARGE_THRESH_BAT0 = lib.mkIf config.services.tlp.batteryThreshold.enable (builtins.toString config.services.tlp.batteryThreshold.stop);
    };
  };
}

