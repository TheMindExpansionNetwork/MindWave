#!/bin/bash
# backup-mindwave.sh - Backup database and generated content

BACKUP_DIR="/home/ubuntu/backups/mindwave"
DATA_DIR="/home/ubuntu/clawd/skills/MindWave"
DATE=$(date +%Y%m%d-%H%M)

mkdir -p "$BACKUP_DIR"

echo "[$(date)] Starting backup..."

# Backup SQLite database
if [ -f "$DATA_DIR/server/database.sqlite" ]; then
    cp "$DATA_DIR/server/database.sqlite" "$BACKUP_DIR/db-$DATE.sqlite"
    echo "✅ Database backed up"
fi

# Backup generated music (last 7 days)
find "$DATA_DIR/outputs/music" -name "*.mp3" -mtime -7 -exec cp {} "$BACKUP_DIR/" \;
echo "✅ Recent music backed up"

# Backup LoRA models
if [ -d "$DATA_DIR/models/lora" ]; then
    tar -czf "$BACKUP_DIR/lora-models-$DATE.tar.gz" -C "$DATA_DIR/models" lora/
    echo "✅ LoRA models backed up"
fi

# Backup datasets metadata
if [ -d "$DATA_DIR/datasets" ]; then
    tar -czf "$BACKUP_DIR/datasets-$DATE.tar.gz" -C "$DATA_DIR" datasets/
    echo "✅ Datasets backed up"
fi

# Cleanup old backups (keep last 7 days)
find "$BACKUP_DIR" -name "*.sqlite" -mtime +7 -delete
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete

echo "[$(date)] Backup complete: $BACKUP_DIR"

# Upload to cloud (if configured)
if [ -n "$CLOUD_BACKUP_BUCKET" ]; then
    aws s3 sync "$BACKUP_DIR" "s3://$CLOUD_BACKUP_BUCKET/mindwave/" --delete
    echo "✅ Uploaded to cloud storage"
fi
