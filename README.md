# Upper

Generic container that archives Podman named volumes and uploads them to Google Drive via [rclone](https://rclone.org). Designed to run as a **oneshot** container triggered by a **systemd timer** via Podman Quadlets.
- *Disclaimer: Generated with AI. This is a very simple project, but still, keep best security practices in mind and audit before using.*

## How it works

1. Archives everything under `/data` into a compressed `.tar.xz` (LZMA2)
2. Uploads the archive to a configured rclone remote
3. Prunes remote backups older than a configurable retention period
4. Exits — the timer handles scheduling

## Configuration

| Variable | Default | Description |
|---|---|---|
| `RCLONE_REMOTE` | *(required)* | rclone remote name (e.g. `gdrive`) |
| `RCLONE_PATH` | *(required)* | Remote directory path (e.g. `Backups/vaultwarden`) |
| `RETAIN_DAYS` | `30` | Delete remote backups older than N days |
| `BACKUP_NAME` | `backup` | Archive filename prefix |
| `DRY_RUN` | `false` | Skip upload/prune (for testing) |

## Volume mounts

| Container path | Purpose |
|---|---|
| `/data` | Source data to back up (mount read-only) |
| `/config/rclone/rclone.conf` | Pre-authenticated rclone config (mount read-only) |

## Usage

```bash
podman run --rm \
  -v my-volume:/data:ro \
  -v ~/.config/rclone/rclone.conf:/config/rclone/rclone.conf:ro \
  -e RCLONE_REMOTE=gdrive \
  -e RCLONE_PATH=Backups/my-service \
  -e BACKUP_NAME=my-service \
  ghcr.io/<username>/upper:latest
```

> **Note:** If bind-mounting host directories (instead of Podman named volumes) on SELinux-enabled systems (Fedora, RHEL), add `:z` to the volume flags (e.g. `-v /path:/data:ro,z`).
