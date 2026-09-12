# Google Cloud Storage Backups and Restore Guide

This guide describes how backup and restore operations work across services using **Restic snapshots** stored in Google Cloud Storage (GCS) buckets.

---

## 1. System Overview

Backups are defined declaratively within each service module (e.g., `modules/services/silverbullet.nix`, `modules/services/immich.nix`, `modules/services/frigate.nix`) using standard NixOS `services.restic.backups.<service-name>` options.

- **Automated Backup Timers**: Systemd timers (`restic-backups-<service-name>.timer`) start systemd backup jobs (`restic-backups-<service-name>.service`).
- **NixOS Generated Wrappers**: NixOS automatically builds wrapper binaries named `restic-<service-name>` on `$PATH` (`restic-silverbullet`, `restic-immich`, `restic-frigate`). These wrappers automatically export all required repository credentials (`RESTIC_REPOSITORY`, `RESTIC_PASSWORD_FILE`, `GOOGLE_APPLICATION_CREDENTIALS`, and `RESTIC_CACHE_DIR`).
- **Authentication**: Service Account JSON keys decrypted via `sops-nix` (`/run/secrets/services/<service-name>/gcs-backup-key`).
- **Pruning**: Automatic retention pruning (`keep-daily: 7`, `keep-weekly: 4`, `keep-monthly: 12`) runs `restic forget --prune` after every backup.

### GCS Destination Repository Schema

Restic repositories are structured in GCS as:

```
gs:<bucket-name>:/<hostname>/<service-name>
```

Examples:
- **Silverbullet**: `gs:silverbullet-backup-66ea520add6c51fb:/ghost-gs60/silverbullet`
- **Immich**: `gs:immich-backup-66ea520add6c51fb:/ghost-gs60/immich`
- **Frigate**: `gs:frigate-backup-66ea520add6c51fb:/ghost-gs60/frigate`

---

## 2. Operations & Management

Using the official NixOS generated wrappers (`restic-<service>`), you can interact with any restic repository without having to manually set environment variables or passwords.

### Show Active Backup Timers

```bash
systemctl list-timers "restic-backups-*"
```

### Start a Backup Job Manually

```bash
run0 systemctl start restic-backups-<service-name>.service
```

### View Backup Service Logs

```bash
journalctl -u restic-backups-<service-name>.service -f
```

---

## 3. Official Restore Procedures

NixOS provides pre-configured wrapper scripts (`restic-<service-name>`) for each service backup job.

---

### Procedure A: Standard Service Restore (Same Host)

Use this procedure if local data or a database is corrupted and needs to be restored to a clean snapshot.

#### Step 1: Stop the Service
Stop the target systemd service to prevent concurrent state writes:

```bash
run0 systemctl stop <service-name>.service
```

Example:
```bash
run0 systemctl stop silverbullet.service
```

#### Step 2: List Available Snapshots
Use the official wrapper to query the repository:

```bash
run0 restic-<service-name> snapshots
```

Example:
```bash
run0 restic-silverbullet snapshots
```

#### Step 3: Inspect Snapshot Contents (Optional)
Check the files in a specific snapshot ID or `latest`:

```bash
run0 restic-<service-name> ls latest
```

#### Step 4: Perform the Restore
Restore files directly to disk:

```bash
run0 restic-<service-name> restore latest --target /
```

Example:
```bash
run0 restic-silverbullet restore latest --target /
```

#### Step 5: Fix File Ownership
Ensure restored files match the system service user/group permissions:

```bash
run0 chown -R <service-user>:<service-group> /var/lib/<service-name>
```

Examples:
```bash
run0 chown -R silverbullet:silverbullet /var/lib/silverbullet
run0 chown -R immich:immich /var/lib/immich
run0 chown -R frigate:frigate /var/lib/frigate
```

#### Step 6: Start the Service and Verify
Start the service and check the logs:

```bash
run0 systemctl start <service-name>.service
journalctl -u <service-name>.service -f
```

---

### Procedure B: FUSE Mount (Inspect or Selective Restore)

You can mount the restic snapshot repository as a read-only FUSE directory to browse or copy specific files interactively:

```bash
# 1. Create a mount target
mkdir -p /tmp/restic-mount

# 2. Mount repository
run0 restic-<service-name> mount /tmp/restic-mount

# 3. Browse files in another terminal / shell
ls -la /tmp/restic-mount/snapshots/latest/

# 4. Unmount when finished
fusermount -u /tmp/restic-mount
```

---

### Procedure C: Restoring Backup to a New Host

When moving a service or restoring onto a new machine (where the source host name in the GCS path differs):

#### Step 1: Stop the Target Service on New Host
```bash
run0 systemctl stop <service-name>.service
```

#### Step 2: Run Restore Overriding the Source Repository Path
Override the `RESTIC_REPOSITORY` environment variable to point to the source hostname:

```bash
run0 env GOOGLE_APPLICATION_CREDENTIALS=/run/secrets/services/<service-name>/gcs-backup-key \
  RESTIC_REPOSITORY="gs:<bucket-name>:/<source-hostname>/<service-name>" \
  RESTIC_PASSWORD_FILE=/run/secrets/services/<service-name>/gcs-backup-key \
  restic restore latest --target /
```

Example (moving `silverbullet` from `ghost-gs60` to `latitude-7390`):
```bash
run0 env GOOGLE_APPLICATION_CREDENTIALS=/run/secrets/services/silverbullet/gcs-backup-key \
  RESTIC_REPOSITORY="gs:silverbullet-backup-66ea520add6c51fb:/ghost-gs60/silverbullet" \
  RESTIC_PASSWORD_FILE=/run/secrets/services/silverbullet/gcs-backup-key \
  restic restore latest --target /
```

#### Step 3: Apply Ownership and Start Service
```bash
run0 chown -R <service-user>:<service-group> /var/lib/<service-name>
run0 systemctl start <service-name>.service
```


