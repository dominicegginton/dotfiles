{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Boot verbosity and logging
  boot.consoleLogLevel = lib.mkDefault 0; # Log all boot messages
  boot.initrd.verbose = lib.mkDefault false; # Disable verbose initrd

  # Boot loader configuration
  boot.loader = {
    systemd-boot.enable = lib.mkDefault true; # Enable systemd-boot by default
    systemd-boot.configurationLimit = lib.mkDefault 3; # Limit the number of generations in /boot to save space
    efi.canTouchEfiVariables = lib.mkDefault true; # Allow EFI variable modification
    efi.efiSysMountPoint = lib.mkForce "/boot"; # Enforce /boot as EFI mount point
  };

  # Boot splash screen
  boot.plymouth = {
    enable = lib.mkDefault true; # Enable plymouth boot splash
    theme = lib.mkForce pkgs.plymouth-theme.name; # Enforce custom boot theme
    themePackages = lib.mkForce [ pkgs.plymouth-theme ]; # Enforce theme package
  };

  boot.kernel.sysctl = {
    "net.ipv4.tcp_syncookies" = lib.mkDefault "1"; # Enable TCP SYN cookies
    "kernel.randomize_va_space" = lib.mkDefault 2; # Enable full ASLR

    # Restrict kernel pointer exposure (restrict to root/admins)
    "kernel.kptr_restrict" = lib.mkForce 2;

    # Restrict dmesg access to root/admins
    "kernel.dmesg_restrict" = lib.mkDefault 1;

    # Append PID to core dump filenames to prevent overwriting/symlink attacks
    "kernel.core_uses_pid" = lib.mkDefault 1;

    # Restrict unprivileged eBPF access
    "kernel.unprivileged_bpf_disabled" = lib.mkDefault 1;

    # Restrict BPF JIT compiler to root
    "net.core.bpf_jit_harden" = lib.mkDefault 2;

    # Disable core dump pattern to user space
    "fs.suid_dumpable" = lib.mkDefault 0;

    # Restrict ptrace scope to children (prevents processes ptracing non-child processes)
    "kernel.yama.ptrace_scope" = lib.mkDefault 1;

    # Restrict loading TTY line disciplines to prevent unprivileged exploits
    "dev.tty.ldisc_autoload" = lib.mkDefault 0;

    # Restrict userfaultfd() syscall to prevent use-after-free heap exploits
    "vm.unprivileged_userfaultfd" = lib.mkDefault 0;

    # Restrict unprivileged use of performance events (KSPP recommendation)
    "kernel.perf_event_paranoid" = lib.mkDefault 3;

    # Disable magic SysRq key combination entirely to prevent console hijacking
    "kernel.sysrq" = lib.mkDefault 0;

    # Maximize ASLR entropy for mmap allocations (KSPP x86_64 recommendation)
    "vm.mmap_rnd_bits" = lib.mkDefault 32;
    "vm.mmap_rnd_compat_bits" = lib.mkDefault 16;

    # Prevent TOCTOU symlink/hardlink attacks in world-writable sticky directories
    "fs.protected_symlinks" = lib.mkDefault 1;
    "fs.protected_hardlinks" = lib.mkDefault 1;
    "fs.protected_fifos" = lib.mkDefault 2;
    "fs.protected_regular" = lib.mkDefault 2;

    # Limit maximum number of processes/PIDs to prevent fork bombs
    "kernel.pid_max" = lib.mkForce 65536;

    # Spoof protection (reverse path filtering)
    "net.ipv4.conf.all.rp_filter" = lib.mkDefault 1;
    "net.ipv4.conf.default.rp_filter" = lib.mkDefault 1;

    # Disable IP packet forwarding (unless explicitly routing)
    "net.ipv4.ip_forward" = lib.mkDefault 0;
    "net.ipv6.conf.all.forwarding" = lib.mkDefault 0;
    "net.ipv6.conf.default.forwarding" = lib.mkDefault 0;

    # Ignore outgoing ICMP redirects (don't send redirects)
    "net.ipv4.conf.all.send_redirects" = lib.mkDefault 0;
    "net.ipv4.conf.default.send_redirects" = lib.mkDefault 0;

    # Protect against ICMP redirects (don't accept redirects)
    "net.ipv4.conf.all.accept_redirects" = lib.mkDefault 0;
    "net.ipv4.conf.default.accept_redirects" = lib.mkDefault 0;
    "net.ipv6.conf.all.accept_redirects" = lib.mkDefault 0;
    "net.ipv6.conf.default.accept_redirects" = lib.mkDefault 0;
    "net.ipv4.conf.all.secure_redirects" = lib.mkDefault 0;
    "net.ipv4.conf.default.secure_redirects" = lib.mkDefault 0;

    # Disable IP source routing (prevents specifying packet paths)
    "net.ipv4.conf.all.accept_source_route" = lib.mkDefault 0;
    "net.ipv4.conf.default.accept_source_route" = lib.mkDefault 0;
    "net.ipv6.conf.all.accept_source_route" = lib.mkDefault 0;
    "net.ipv6.conf.default.accept_source_route" = lib.mkDefault 0;

    # Ignore ICMP echo requests (ping) broadcast
    "net.ipv4.icmp_echo_ignore_broadcasts" = lib.mkDefault 1;

    # Ignore bogus ICMP errors
    "net.ipv4.icmp_ignore_bogus_error_responses" = lib.mkDefault 1;

    # Protect against RFC 1337 time-wait assassination attacks
    "net.ipv4.tcp_rfc1337" = lib.mkDefault 1;

    # Reduce time sockets stay in TIME_WAIT state to resist resource exhaustion
    "net.ipv4.tcp_fin_timeout" = lib.mkDefault 15;

    # Limit SYN backlog queue size
    "net.ipv4.tcp_max_syn_backlog" = lib.mkDefault 2048;

    # Disable TCP timestamps to prevent system uptime and clock leaking
    "net.ipv4.tcp_timestamps" = lib.mkDefault 0;

    # Enable kernel stack erasing (Clang 15+ compiler feature in Linux 6.17+)
    "kernel.stack_erasing" = lib.mkDefault 1;

    # Enable IPv6 privacy extensions
    "net.ipv6.conf.all.use_tempaddr" = lib.mkDefault 2;
    "net.ipv6.conf.default.use_tempaddr" = lib.mkDefault 2;

    # --- Performance Tuning (Safe settings from Linux kernel tuning guide) ---
    # Adjust swappiness to prefer RAM over swap for improved responsiveness
    "vm.swappiness" = lib.mkDefault 10;

    # Tune dirty page writeback ratios for improved write I/O performance
    "vm.dirty_background_ratio" = lib.mkDefault 10;
    "vm.dirty_ratio" = lib.mkDefault 40;

    # Reboot automatically 10 seconds after a kernel panic
    "kernel.panic" = lib.mkDefault 10;

    # Increase network buffer sizes for high-bandwidth connections
    "net.core.rmem_max" = lib.mkDefault 8388608;
    "net.core.wmem_max" = lib.mkDefault 8388608;
    "net.ipv4.tcp_rmem" = lib.mkDefault "4096 87380 8388608";
    "net.ipv4.tcp_wmem" = lib.mkDefault "4096 87380 8388608";

    # Adjust CFS scheduler parameters to decrease task context-switch frequency and improve CPU throughput
    "kernel.sched_min_granularity_ns" = lib.mkDefault 10000000;
    "kernel.sched_wakeup_granularity_ns" = lib.mkDefault 15000000;

    # Increase system-wide maximum file descriptor limit to handle high-concurrency workloads
    "fs.file-max" = lib.mkDefault 100000;

    # Increase maximum queue length for pending network connections
    "net.core.somaxconn" = lib.mkDefault 1024;

    # Enable TCP window scaling to utilize large TCP window sizes on high-bandwidth links
    "net.ipv4.tcp_window_scaling" = lib.mkDefault 1;
  };

  # Cryptographic modules required for early boot FIPS self-tests in initrd
  boot.initrd.kernelModules = lib.optionals (!config.wsl.enable) [
    "tcrypt" # Cryptographic self-tests
    "ansi_cprng" # Pseudo-random number generator
    "drbg" # Deterministic Random Bit Generator
    "jitterentropy" # Entropy source
    "hmac" # Keyed-Hash Message Authentication Code
    "sha1" # Secure Hash Algorithm 1
    "sha224" # Secure Hash Algorithm 224
    "sha256" # Secure Hash Algorithm 256
    "sha384" # Secure Hash Algorithm 384
    "sha512" # Secure Hash Algorithm 512
    "aes" # Advanced Encryption Standard
    "cbc" # Cipher Block Chaining
    "ctr" # Counter mode
    "xts" # XTS mode
    "gcm" # Galois/Counter Mode
    "ccm" # Counter with CBC-MAC
    "ghash" # Galois Hash
    "cryptomgr" # Crypto manager
    "crypto_user" # Crypto user configuration API
  ];

  boot.kernelParams = [
    "fips=1" # Enable FIPS mode
    "audit=1" # Enable auditing
    "audit_backlog_limit=8192" # Increase audit backlog
  ]
  ++ lib.optionals (!config.wsl.enable) [
    "page_alloc.shuffle=1" # Randomize page allocator freelist
    "randomize_kstack_offset=on" # Randomize kernel stack offset on syscalls
    "vsyscall=none" # Disable legacy vsyscalls
    "init_on_alloc=1" # Zero-initialize memory allocations
    "init_on_free=1" # Zero-initialize freed memory
    "slab_nomerge" # Disable merging of slab caches
    "lockdown=integrity" # Enable Lockdown LSM in integrity mode to restrict unsigned module/kexec loading
    "page_poison=1" # Overwrite freed pages with poison patterns to prevent info leaks (PAGE_POISONING=Y)
    "debugfs=off" # Completely disable debugfs to reduce kernel attack surface (DEBUG_FS=is not set)
    "nohibernate" # Disable kernel hibernation to prevent kernel replacement/tampering (HIBERNATION=is not set)
    "oops=panic" # Panic on oopses to stop exploits instead of letting them continue in unstable states
    "random.trust_cpu=off" # Distrust CPU RNG (like RDRAND) for cryptographical security
    "random.trust_bootloader=off" # Distrust bootloader-provided entropy for security (e.g. systemd-boot seed)
    "intel_iommu=on" # Enable IOMMU to mitigate physical DMA attacks
    "amd_iommu=on" # Enable IOMMU to mitigate physical DMA attacks
    "amd_iommu=force_isolation" # Enforce strict AMD IOMMU hardware isolation
    "iommu=force" # Force system to utilize IOMMU to mitigate DMA attacks
    "iommu.passthrough=0" # Prevent bypass of the IOMMU translation layers
    "iommu.strict=1" # Perform strict TLB invalidation for the IOMMU to avoid stale data leakage
    "efi=disable_early_pci_dma" # Disable early busmaster DMA on PCI bridges
  ];

  # Harden kernel security by default
  security.lockKernelModules = lib.mkDefault true;
  security.protectKernelImage = lib.mkDefault true;
  security.unprivilegedUsernsClone = lib.mkDefault true;
}
