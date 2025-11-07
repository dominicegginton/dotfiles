{ inputs, lib, config, ... }:

{
  imports = with inputs.nixos-hardware.nixosModules; [
    common-pc-laptop
    common-pc-laptop-ssd
    dell-latitude-7390
  ];
  fileSystems."/".device = "/dev/disk/by-uuid/2d59d3c7-44f3-4fd3-9c7a-64b2ec9f21a0";
  fileSystems."/".fsType = "ext4";
  fileSystems."/boot".device = "/dev/disk/by-uuid/8543-16DB";
  fileSystems."/boot".fsType = "vfat";
  swapDevices = [{ device = "/dev/disk/by-uuid/4e74fa9d-47d7-4a43-9cec-01d4fdd1a1a2"; }];
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "vhost_vsock" "i2c-dev" "ddcci_backlight" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];

  display.niri.enable = true;

  boot.kernel.sysctl = {
    # Set swappiness to only swap if you really have to
    # The sysctl swappiness parameter determines the kernel's preference for pushing anonymous pages or page cache to disk in memory-starved situations.
    # A low value causes the kernel to prefer freeing up open files (page cache), a high value causes the kernel to try to use swap space,
    # and a value of 100 means IO cost is assumed to be equal.
    "vm.swappiness" = 1;

    # Adjust cache pressure
    # The value controls the tendency of the kernel to reclaim the memory which is used for caching of directory and inode objects (VFS cache). 
    # Lowering it from the default value of 100 makes the kernel less inclined to reclaim VFS cache (do not set it to 0, this may produce out-of-memory conditions)
    "vm.vfs_cache_pressure" = 30;

    # Contains, as a bytes of total available memory that contains free pages and reclaimable
    # pages, the number of pages at which a process which is generating disk writes will itself start
    # writing out dirty data.
    "vm.dirty_bytes" = 1073741824; # 1 GB

    # Optimize storage related settings
    # Contains, as a bytes of total available memory that contains free pages and reclaimable
    # pages, the number of pages at which the background kernel flusher threads will start writing out
    # dirty data.
    "vm.dirty_background_ratio" = 5;

    # The kernel flusher threads will periodically wake up and write old data out to disk.  
    # This tunable expresses the interval between those wakeups, in 100'ths of a second (Default is 500).
    "vm.dirty_writeback_centisecs" = 1000; # 10 seconds

    # page-cluster controls the number of pages up to which consecutive pages are read in from swap in a single attempt. 
    # This is the swap counterpart to page cache readahead. The mentioned consecutivity is not in terms of virtual/physical addresses, 
    # but consecutive on swap space - that means they were swapped out together. (Default is 3)
    # increase this value to 1 or 2 if you are using physical swap (1 if ssd, 2 if hdd)
    "vm.page-cluster" = 0; # Set to 0 for SSD

    # Allow unprivileged users to bind ports below 1024
    "net.ipv4.ip_unprivileged_port_start" = 0;

    # Increase max_user_watches
    # Defines the maximum number of file watches that can be registered.
    "fs.inotify.max_user_watches" = 1048576;

    # Set size of file handles and inode cache
    # Sets the maximum number of file descriptors that can be allocated.
    "fs.file-max" = 4194304;

    # Increase writeback interval for xfs
    # Defines the interval (in centiseconds) at which the XFS kernel threads flush data to disk.
    "fs.xfs.xfssyncd_centisecs" = 10000; # 100 seconds

    # Defines the maximum number of asynchronous I/O requests that can be in progress at a given time.
    "fs.aio-max-nr" = 1000000; # 1 million

    # Disable core dumps
    # Redirect core dumps to /dev/null to disable them.
    "kernel.core_pattern" = "/dev/null";

    # Increase the sched_rt_runtime_us to mitigate issues:
    # sched: RT throttling activated
    # Defines the time (in microseconds) that real-time tasks can run without being throttled.
    "kernel.sched_rt_runtime_us" = 980000;

    # This action will speed up your boot and shutdown, because one less module is loaded.
    # Additionally, disabling watchdog timers increases performance and lowers power consumption.
    # Disable NMI watchdog
    "kernel.nmi_watchdog" = 0;

    # Enable the sysctl setting kernel.unprivileged_userns_clone to allow normal users to run unprivileged containers.
    "kernel.unprivileged_userns_clone" = 1;

    # Hide any kernel messages from the console
    # Adjust the console log level to suppress messages.
    "kernel.printk" = "3 3 3 3";

    # Disable Kexec, which allows replacing the current running kernel. 
    # Enhances security by preventing kernel replacement.
    "kernel.kexec_load_disabled" = 1;

    # Increase the maximum connections
    # The upper limit on how many connections the kernel will accept (default 4096 since kernel version 5.6):
    "net.core.somaxconn" = 8192;

    # Enable SysRQ for rebooting the machine properly if it freezes.
    # Useful for emergency recovery.
    "kernel.sysrq" = 1;

    # Allows a large number of processes and threads to be managed
    # Sets the maximum number of process IDs that can be allocated.
    "kernel.pid_max" = 262144;

    # Help prevent packet loss during high traffic periods.
    # Defines the maximum number of packets that can be queued on the network device input queue.
    "net.core.netdev_max_backlog" = 65536;

    # Default socket receive buffer size, improve network performance & applications that use sockets. Adjusted for 8GB RAM.
    "net.core.rmem_default" = 1048576; # 1 MB

    # Maximum socket receive buffer size, determine the amount of data that can be buffered in memory for network operations. Adjusted for 8GB RAM.
    "net.core.rmem_max" = 67108864; # 64 MB

    # Default socket send buffer size, improve network performance & applications that use sockets. Adjusted for 8GB RAM.
    "net.core.wmem_default" = 1048576; # 1 MB

    # Maximum socket send buffer size, determine the amount of data that can be buffered in memory for network operations. Adjusted for 8GB RAM.
    "net.core.wmem_max" = 67108864; # 64 MB

    # reduce the chances of fragmentation
    "net.ipv4.ipfrag_high_threshold" = 5242880; # 5 MB

    # allow tcp window size to grow beyond its default maximum value.
    "net.ipv4.tcp_window_scaling" = 1;

    # define the memory reserved for TCP read operations.
    "net.ipv4.tcp_rmem" = "4096 87380 67108864";

    # define the memory reserved for tcp write operations
    "net.ipv4.tcp_wmem" = "4096 65536 67108864";

    # optimizes for low latency and high throughput
    "net.ipv4.tcp_congestion_control" = "bbr";

    # increases the frequency at which the kernel's scheduler runs, which can improve system responsiveness.
    "kernel.hz" = 1000;

    # split lock mitigate can slow down performance in some applications.
    "kernel.split_lock_mitigate" = 0;
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;
  hardware.bluetooth.enable = true;
  hardware.intel-gpu-tools.enable = true;
  services.logind.extraConfig = "HandlePowerKey=suspend";
  services.logind.lidSwitch = "suspend";
  services.upower.enable = true;
  services.tlp.enable = true;
  services.tlp.batteryThreshold.enable = true;
  services.printing.enable = true;
  display.gnome.enable = true;
  programs.vscode.enable = true;
  virtualisation.docker.enable = true;
  topology.self.hardware.info = "Dell Latitude 7390 2-in-1";
}
