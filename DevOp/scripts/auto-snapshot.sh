#!/bin/bash

# === CONFIGURATION ===
PROJECT_ID="your-project-id"              # <-- change to your project ID
ZONE="your-vm-zone"                        # e.g., asia-southeast1-b
INSTANCE_NAME="your-instance-name"         # your VM name
DISK_NAME="your-disk-name"                 # your disk name attached to VM
SNAPSHOT_NAME="auto-snap-$(date +'%Y%m%d-%H%M%S')"  # e.g., auto-snap-20250427-2330
PRE_SCRIPT="/opt/snapshot_hooks/pre_snapshot.sh"
POST_SCRIPT="/opt/snapshot_hooks/post_snapshot.sh"
LOG_FILE="/var/log/auto_snapshot.log"

# === START ===
echo "[AUTO-SNAPSHOT] === START ===" | tee -a "$LOG_FILE"
echo "[AUTO-SNAPSHOT] Time: $(date)" | tee -a "$LOG_FILE"

# 1. Run Pre-Snapshot Preparation
if [ -f "$PRE_SCRIPT" ]; then
    echo "[AUTO-SNAPSHOT] Running Pre-Snapshot Script..." | tee -a "$LOG_FILE"
    bash "$PRE_SCRIPT"
else
    echo "[AUTO-SNAPSHOT] No Pre-Snapshot Script found." | tee -a "$LOG_FILE"
fi

# 2. Trigger Snapshot via gcloud CLI
echo "[AUTO-SNAPSHOT] Creating snapshot $SNAPSHOT_NAME..." | tee -a "$LOG_FILE"

gcloud compute disks snapshot "$DISK_NAME" \
    --project="$PROJECT_ID" \
    --zone="$ZONE" \
    --snapshot-names="$SNAPSHOT_NAME" \
    --quiet

if [ $? -eq 0 ]; then
    echo "[AUTO-SNAPSHOT] Snapshot $SNAPSHOT_NAME created successfully." | tee -a "$LOG_FILE"
else
    echo "[AUTO-SNAPSHOT] Snapshot FAILED!" | tee -a "$LOG_FILE"
    # Optionally: exit 1 to stop post-script if snapshot fails
fi

# 3. Run Post-Snapshot Recovery
if [ -f "$POST_SCRIPT" ]; then
    echo "[AUTO-SNAPSHOT] Running Post-Snapshot Script..." | tee -a "$LOG_FILE"
    bash "$POST_SCRIPT"
else
    echo "[AUTO-SNAPSHOT] No Post-Snapshot Script found." | tee -a "$LOG_FILE"
fi

echo "[AUTO-SNAPSHOT] === FINISH ===" | tee -a "$LOG_FILE"
exit 0