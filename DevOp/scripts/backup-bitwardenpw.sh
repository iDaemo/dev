#!/bin/bash
set -e

# CONFIGURATION
EMAIL="nattapoom@hotmail.com"
BW_PASSWORD="Nupuan338866"
EXPORT_PASSWORD="Nupuan338866"
RCLONE_REMOTE="gdrive"
RCLONE_FOLDER="bitwarden-backups"
EXPORT_FILE="/tmp/backup-$(date +%F).json"

# Load session from previous login if exists
if [ -f ~/.bw_session ]; then
    export BW_SESSION=$(cat ~/.bw_session)
fi

# Try unlocking (in case already logged in)
if ! bw unlock --password "$BW_PASSWORD" --raw > ~/.bw_session; then
    echo "Unlock failed, trying login..."
    bw login "$EMAIL" "$BW_PASSWORD" --raw > ~/.bw_session
fi
export BW_SESSION=$(cat ~/.bw_session)

# Sync vault
bw sync

# Export encrypted vault
echo "Exporting Bitwarden vault..."
bw export --format encrypted_json --output "$EXPORT_FILE" --password "$EXPORT_PASSWORD"

# Upload to Google Drive
echo "Uploading to Google Drive..."
rclone copy "$EXPORT_FILE" "$RCLONE_REMOTE:$RCLONE_FOLDER"

# Clean up
echo "Cleaning up..."
rm -f "$EXPORT_FILE"

echo "✅ Bitwarden backup completed successfully!"