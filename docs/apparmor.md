# AppArmor Profile Inspection & Operational Guide

AppArmor is enabled system-wide (`modules/security/apparmor.nix`) to enforce mandatory access control and application sandboxing.

## 1. Inspecting AppArmor Status & Active Profiles

To inspect loaded profiles and verify which processes are currently confined or in enforce/complain mode:

```bash
# Check AppArmor status, loaded profiles, and confined processes
run0 aa-status
```

Example output:

```text
apparmor module is loaded.
42 profiles are loaded.
38 profiles are in enforce mode.
4 profiles are in complain mode.
12 processes have profiles defined.
```

## 2. Debugging AppArmor Denials & Audit Logs

When an application is blocked by AppArmor or crashes unexpectedly, check `journald` for AppArmor AUDIT/DENIED messages:

```bash
# Filter system logs for AppArmor denial events
run0 journalctl -k --grep="apparmor="

# Follow real-time AppArmor audit events
run0 journalctl -kf --grep="apparmor="
```

## 3. Managing Profiles at Runtime

To temporarily switch a profile to complain mode (log violations without blocking) or enforce mode:

```bash
# Put a profile into complain mode for troubleshooting
run0 aa-complain /path/to/binary

# Re-enforce a profile
run0 aa-enforce /path/to/binary

# Reload all AppArmor profiles
run0 systemctl reload apparmor.service
```

## 4. Custom AppArmor Profiles in NixOS

Custom AppArmor profiles can be declared in your NixOS configuration under `security.apparmor.policies`:

```nix
security.apparmor.policies."my-profile" = {
  state = "enforce";
  profile = ''
    #include <tunables/global>

    /path/to/binary {
      #include <abstractions/base>

      /path/to/binary mr,
      /path/to/data/* rw,
    }
  '';
};
```
