#!/bin/bash
set -euo pipefail

# ── Required env vars ─────────────────────────────────────────────
: "${RCLONE_REMOTE:?RCLONE_REMOTE is required}"
: "${RCLONE_PATH:?RCLONE_PATH is required}"

# ── Optional env vars ─────────────────────────────────────────────
RETAIN_DAYS="${RETAIN_DAYS:-30}"
BACKUP_NAME="${BACKUP_NAME:-backup}"
DRY_RUN="${DRY_RUN:-false}"

# ── Derived values ────────────────────────────────────────────────
TIMESTAMP="$(date +%m_%d_%Y)"
ARCHIVE="${BACKUP_NAME}_${TIMESTAMP}.tar.xz"
DEST="${RCLONE_REMOTE}:${RCLONE_PATH}"
WORKDIR="/tmp/upper"

log() { echo "[backup] $*"; }

# ── Validate ──────────────────────────────────────────────────────
if [ ! -d /data ]; then
    log "ERROR: /data does not exist. Mount a volume to /data."
    exit 1
fi

# ── Archive ───────────────────────────────────────────────────────
mkdir -p "${WORKDIR}"
log "Creating archive: ${ARCHIVE}"
tar -cJf "${WORKDIR}/${ARCHIVE}" -C /data .
log "Archive size: $(du -h "${WORKDIR}/${ARCHIVE}" | cut -f1)"

# ── Upload ────────────────────────────────────────────────────────
if [ "${DRY_RUN}" = "true" ]; then
    log "DRY_RUN: would upload ${ARCHIVE} → ${DEST}/"
    log "DRY_RUN: would prune remote backups older than ${RETAIN_DAYS} days"
else
    log "Uploading ${ARCHIVE} → ${DEST}/"
    rclone copy "${WORKDIR}/${ARCHIVE}" "${DEST}/" --log-level INFO

    log "Pruning remote backups older than ${RETAIN_DAYS} days"
    rclone delete "${DEST}/" --min-age "${RETAIN_DAYS}d" --log-level INFO
fi

# ── Cleanup ───────────────────────────────────────────────────────
rm -rf "${WORKDIR}"
log "Done."
