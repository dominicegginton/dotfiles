{
  consfig,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.boot;
in {
  config = {
    boot = {
      consoleLogLevel = 0;
      initrd.verbose = false;
      kernelModules = ["vhost_vsock"];
      kernelParams = [
        "boot.shell_on_fail"
        "loglevel=3"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
      ];
      kernel.sysctl = {
        "net.ipv4.ip_forward" = 1;
        "net.ipv6.conf.all.forwarding" = 1;
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";
      };
    };
  };
}
