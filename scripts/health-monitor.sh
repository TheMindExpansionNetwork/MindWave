#!/bin/bash
# health-monitor.sh - Check all services and restart if needed

LOG_FILE="/home/ubuntu/clawd/skills/MindWave/logs/health-monitor.log"
mkdir -p "$(dirname "$LOG_FILE")"

echo "[$(date)] Health check starting..." >> "$LOG_FILE"

# Check ACE-Step API
if ! /home/ubuntu/clawd/skills/MindWave/scripts/ace-step-service-manager.sh status > /dev/null 2>&1; then
    echo "[$(date)] ACE-Step API down - restarting..." >> "$LOG_FILE"
    /home/ubuntu/clawd/skills/MindWave/scripts/ace-step-service-manager.sh restart
fi

# Check ComfyUI
if ! /home/ubuntu/clawd/skills/MindWave/scripts/comfyui-service-manager.sh status > /dev/null 2>&1; then
    echo "[$(date)] ComfyUI down - restarting..." >> "$LOG_FILE"
    /home/ubuntu/clawd/skills/MindWave/scripts/comfyui-service-manager.sh restart
fi

# Check disk space
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 85 ]; then
    echo "[$(date)] WARNING: Disk usage at ${DISK_USAGE}%" >> "$LOG_FILE"
    
    # Cleanup old outputs
    find /home/ubuntu/clawd/skills/MindWave/outputs -name "*.mp3" -mtime +30 -delete
    echo "[$(date)] Cleaned up old outputs" >> "$LOG_FILE"
fi

# Check GPU memory (if nvidia-smi available)
if command -v nvidia-smi &> /dev/null; then
    GPU_MEM=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits | head -n1)
    if [ "$GPU_MEM" -gt 10000 ]; then
        echo "[$(date)] WARNING: High GPU memory usage: ${GPU_MEM}MB" >> "$LOG_FILE"
    fi
fi

echo "[$(date)] Health check complete" >> "$LOG_FILE"
