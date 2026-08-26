# Google Cloud Storage Backups and Restore Guide

<!-- TODO: Rename backup service, restore package, and documentation files for naming consistency -->

This guide describes how to do backup and restore operations for services.
It uses Google Cloud Storage (GCS) buckets.

---

## 1. Description of the System

The system configuration manages backups.
The system uses the NixOS module `modules/services/gcs-backup.nix`.

- **Operation**: Systemd timers (`gcs-backup-<job-name>.timer`) start systemd services (`gcs-backup-<job-name>.service`).
- **Tool**: The system uses `gcloud storage rsync` to copy data directories to GCS.
- **Authentication**: The system uses a Google Cloud Service Account JSON key. The file path is `/run/secrets/services/<service-name>/gcs-backup-key`.
- **Storage**: Data directories are in the persistent `/persist` filesystem.

### GCS Destination Paths

The backup script organizes files in GCS to prevent overwriting.
It uses this path schema:

```
gs://<bucket-name>/<hostname>/<job-name>/<absolute-path-to-directory>
```

Example for the `silverbullet` service on host `ghost-gs60`:

- **Source**: `/var/lib/silverbullet`
- **GCS Destination**: `gs://<bucket-name>/ghost-gs60/silverbullet/var/lib/silverbullet/`

---

## 2. Interactive Restore Tool (`gcs-restore`)

Use the `gcs-restore` tool in `pkgs/gcs-restore.nix`.
This tool does these steps:

1. It stops the target systemd service.
2. It uses the decrypted `sops` key file to authenticate `gcloud`.
3. It shows a list of hostnames from the bucket. Select one hostname.
4. It does a dry run to show changes.
5. It copies the backup files to the local host.
6. It changes file ownership permissions (`chown`).
7. It starts the systemd service.

### Run the Interactive Restore Tool

Open the repository shell.
Run this command with root privileges:

```bash
run0 gcs-restore
```

### Script Options

You can add these options to the command:

```bash
run0 gcs-restore [OPTIONS]

OPTIONS:
  -s, --service <name>   The service name (e.g., 'silverbullet', 'immich', 'frigate')
  -b, --bucket <gs://..> GCS bucket URI
  -o, --old-host <name>  The source hostname of the backup
  -d, --dir <path>       The target local directory for restore
  -u, --user <name>      The target owner user
  -g, --group <name>     The target owner group
  -k, --key <path>       The path to the Service Account key file
  --delete               Delete local files that are not in the backup
  -y, --yes              Do the restore and do not ask for dry-run confirmation
  -n, --dry-run          Do a dry run only and stop the script
```

---

## 3. Operations and Monitoring

### Show Backup Timers

Run this command to show all active backup timers:

```bash
systemctl list-timers "gcs-backup-*"
```

### Start a Backup Manually

Run this command to start a backup immediately:

```bash
run0 systemctl start gcs-backup-<job-name>.service
```

_Note: Replace `<job-name>` with the service name (e.g., `silverbullet`, `immich`, or `frigate`)._

### Show Backup Logs

Run this command to show the active logs of a backup:

```bash
journalctl -u gcs-backup-<job-name>.service -f
```

---

## 4. Restore Procedures (Manual Steps)

Use these manual steps if you do not use the `gcs-restore` tool.

---

### Procedure A: Restore to the Same Host

Use this procedure if the host fails and you must restore data to the same host.

#### Step 1: Deploy the Host Configuration

1. Use the `deploy-host` script to install the host.
2. The installation makes systemd services and decrypts keys.

#### Step 2: Stop the Service

Stop the service immediately to prevent data corruption:

```bash
run0 systemctl stop <service-name>.service
```

#### Step 3: Authenticate gcloud

Use the decrypted Service Account key file to authenticate:

```bash
run0 gcloud auth activate-service-account --key-file=/run/secrets/services/<service-name>/gcs-backup-key
```

#### Step 4: Do a Dry Run

Do a dry run to verify the connection and show the changes:

```bash
run0 gcloud storage rsync -r -n \
  "gs://<bucket-name>/<hostname>/<job-name><dir>" \
  "<dir>"
```

Example for the `silverbullet` service on host `ghost-gs60`:

```bash
run0 gcloud storage rsync -r -n \
  "gs://<bucket-name>/ghost-gs60/silverbullet/var/lib/silverbullet" \
  "/var/lib/silverbullet"
```

#### Step 5: Do the Restore

Run this command to copy the files from GCS:

```bash
run0 gcloud storage rsync -r \
  "gs://<bucket-name>/<hostname>/<job-name><dir>" \
  "<dir>"
```

#### Step 6: Change File Ownership

Change the owner and group of the files to match the service user:

```bash
run0 chown -R <service-user>:<service-group> "<dir>"
```

Examples:

```bash
# Silverbullet
run0 chown -R silverbullet:silverbullet /var/lib/silverbullet

# Immich
run0 chown -R immich:immich /var/lib/immich

# Frigate
run0 chown -R frigate:frigate /var/lib/frigate
```

#### Step 7: Start the Service and Check Logs

Start the service and check the logs:

```bash
run0 systemctl start <service-name>.service
journalctl -u <service-name>.service -f
```

---

### Procedure B: Move a Service to a Different Host

Use this procedure to move a service from a source host (e.g., `ghost-gs60`) to a target host (e.g., `latitude-7390`).

#### Step 1: Stop the Service on the Source Host

Stop the service on the source host to prevent new writes:

```bash
run0 systemctl stop <service-name>.service
```

#### Step 2: Start a Backup on the Source Host

Run a manual backup to copy the latest files to GCS:

```bash
run0 systemctl start gcs-backup-<job-name>.service
```

#### Step 3: Change the Repository Configuration

1. Open the repository in VS Code.
2. Remove the service from the source host file (e.g., `hosts/ghost-gs60.nix`).
3. Add the service to the target host file (e.g., `hosts/latitude-7390.nix`).
4. Edit the sops secrets file for the target host:
   ```bash
   sops secrets/hosts/<target-hostname>.yaml
   ```
   _Note: Paste the correct `gcs-backup-key` into this file._
5. Commit and push the changes.

#### Step 4: Deploy the Target Host

Deploy the configuration to the target host:

```bash
deploy-host
```

#### Step 5: Stop the Service on the Target Host

Stop the service on the target host:

```bash
run0 systemctl stop <service-name>.service
```

#### Step 6: Copy Files from the Source Host Path

Authenticate and copy files from GCS. Use the source hostname in the GCS path:

```bash
# 1. Authenticate with the target host key file
run0 gcloud auth activate-service-account --key-file=/run/secrets/services/<service-name>/gcs-backup-key

# 2. Copy the files
run0 gcloud storage rsync -r \
  "gs://<bucket-name>/<source-hostname>/<job-name><dir>" \
  "<dir>"
```

Example to move `silverbullet` from `ghost-gs60` to `latitude-7390`:

```bash
run0 gcloud storage rsync -r \
  "gs://<bucket-name>/ghost-gs60/silverbullet/var/lib/silverbullet" \
  "/var/lib/silverbullet"
```

#### Step 7: Change File Ownership

Change the owner and group of the files to match the service user on the target host:

```bash
run0 chown -R <service-user>:<service-group> "<dir>"
```

#### Step 8: Start the Service and Check Logs

Start the service on the target host and check the logs:

```bash
run0 systemctl start <service-name>.service
journalctl -u <service-name>.service -f
```

#### Step 9: Start a New Backup

Start a manual backup on the target host. This makes a new backup path in GCS with the target hostname:

```bash
run0 systemctl start gcs-backup-<job-name>.service
```

Future backups will now automatically run on their timers and upload to:
`gs://<bucket-name>/<new-hostname>/<job-name><dir>`
