{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.security.audit-compliance = {
    enable = lib.mkEnableOption "system auditing, OpenSCAP, and FIPS compliance" // {
      default = true;
    };
    adminEmail = lib.mkOption {
      type = lib.types.str;
      default = "root";
      description = "Email address to send audit space alerts to.";
    };
  };

  config = lib.mkIf config.security.audit-compliance.enable {
    # Install OpenSCAP and standard compliance guides
    environment.systemPackages = with pkgs; [
      openscap
      scap-security-guide
    ];

    # Enable audit daemon and configure settings
    security.auditd = {
      enable = lib.mkDefault (!config.wsl.enable);
      settings = {
        space_left = "10%";
        space_left_action = "ignore";
        admin_space_left = "5%";
        admin_space_left_action = "email";
        action_mail_acct = config.security.audit-compliance.adminEmail;
        num_logs = 10;
        max_log_file = 100;
        max_log_file_action = "rotate";
      };
    };

    # Configure comprehensive system auditing rules
    security.audit = {
      enable = lib.mkDefault (!config.wsl.enable);
      rules = [
        # System auditing configuration modifications
        "-w /etc/audit/ -p wa -k auditconfig"
        "-w /var/log/audit/ -p wa -k auditlog"

        # Module loading and kernel operations
        "-a always,exit -F arch=b64 -S init_module -S finit_module -S delete_module -k modules"

        # Core execution monitoring
        "-a always,exit -F arch=b64 -S execve -k execution"

        # Discretionary access control modifications (chmod, chown)
        "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -k perm_mod"
        "-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -k perm_mod"
        "-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -k perm_mod"

        # Failed file access tracking (EACCES/EPERM)
        "-a always,exit -F arch=b64 -S open -S openat -S creat -S truncate -S ftruncate -F exit=-EACCES -k access"
        "-a always,exit -F arch=b64 -S open -S openat -S creat -S truncate -S ftruncate -F exit=-EPERM -k access"

        # Identity and group management tracking
        "-w /etc/group -p wa -k identity"
        "-w /etc/passwd -p wa -k identity"
        "-w /etc/shadow -p wa -k identity"

        # Login and session changes
        "-w /var/log/lastlog -p wa -k logins"
        "-w /var/run/utmp -p wa -k session"
        "-w /var/log/wtmp -p wa -k session"
        "-w /var/log/btmp -p wa -k session"

        # Network configuration modifications
        "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k network"
        "-w /etc/issue -p wa -k network"
        "-w /etc/hosts -p wa -k network"

        # Mount/unmount actions
        "-a always,exit -F arch=b64 -S mount -S umount2 -k mount"
      ];
    };
  };
}
