{ config, lib, ... }:

{
  # Secure kernel sysctl options (Solène, notashelf, k4yt3x sysctl, and standard security guidelines)
  boot.kernel.sysctl = {
    # Restrict kernel pointer exposure (restrict to root/admins)
    "kernel.kptr_restrict" = lib.mkDefault 2;

    # Restrict dmesg access to root/admins
    "kernel.dmesg_restrict" = lib.mkDefault 1;

    # Restrict BPF JIT compiler to root
    "net.core.bpf_jit_harden" = lib.mkDefault 2;

    # Disable core dump pattern to user space
    "fs.suid_dumpable" = lib.mkDefault 0;

    # Restrict ptrace scope to children (prevents processes ptracing non-child processes)
    "kernel.yama.ptrace_scope" = lib.mkDefault 1;

    # Spoof protection (reverse path filtering)
    "net.ipv4.conf.all.rp_filter" = lib.mkDefault 1;
    "net.ipv4.conf.default.rp_filter" = lib.mkDefault 1;

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

    # Ignore ICMP echo requests (ping) broadcast
    "net.ipv4.icmp_echo_ignore_broadcasts" = lib.mkDefault 1;

    # Ignore bogus ICMP errors
    "net.ipv4.icmp_ignore_bogus_error_responses" = lib.mkDefault 1;
  };

  # Extra boot parameters for security/hardening (NixOS hardened profile defaults), disabled on WSL as WSL uses the host Windows NT kernel
  boot.kernelParams = lib.mkIf (!config.wsl.enable) [
    "page_alloc.shuffle=1" # Randomize page allocator freelist
    "randomize_kstack_offset=on" # Randomize kernel stack offset on syscalls
    "vsyscall=none" # Disable legacy vsyscalls
    "init_on_alloc=1" # Zero-initialize memory allocations
    "init_on_free=1" # Zero-initialize freed memory
    "slab_nomerge" # Disable merging of slab caches
  ];
}
