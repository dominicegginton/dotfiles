{ config, lib, ... }:

{
  options.services.tlp.batteryThreshold = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "TLP Battery Charge Thresholds";
        start = lib.mkOption {
          type = lib.types.int;
          default = 70;
          description = "Battery charge threshold to start charging at.";
        };
        stop = lib.mkOption {
          type = lib.types.int;
          default = 80;
          description = "Battery charge threshold to stop charging at.";
        };
      };
      example = {
        enable = true;
        start = 75;
        stop = 80;
      };
      default = { enable = false; };
      description = "Configure TLP battery charge thresholds.";
    };
    default = { enable = false; };
    description = "TLP power management service.";
  };

  config.services = lib.mkIf config.services.tlp.enable {
    power-profiles-daemon.enable = lib.mkForce false;
    tlp.settings = {
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
    } // lib.optional (config.services.tlp.batteryThreshold.enable && config.display.gnome.enable == false) {
      START_CHARGE_THRESH_BAT0 = config.services.tlp.batteryThreshold.start;
      STOP_CHARGE_THRESH_BAT0 = config.services.tlp.batteryThreshold.stop;
    };
  };
}


