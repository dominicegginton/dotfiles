{ config, lib, ... }:

{
  # Secure kernel sysctl options (Solène, notashelf, k4yt3x sysctl, and standard security guidelines)
  boot.kernel.sysctl = {
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
  };

  # Extra boot parameters for security/hardening (NixOS hardened profile defaults), disabled on WSL as WSL uses the host Windows NT kernel
  boot.kernelParams = lib.mkIf (!config.wsl.enable) [
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
}
