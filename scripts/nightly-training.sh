#!/bin/bash
# scripts/nightly-training.sh - Overnight LoRA training

cd /home/ubuntu/clawd/skills/MindWave

# Log start
echo "[$(date)] Starting nightly training..." >> logs/training.log

# Check for pending training jobs
if [ -f "training/queue/pending.json" ]; then
    echo "[$(date)] Found pending jobs" >> logs/training.log
    
    # Activate environment
    source /home/ubuntu/.conda/etc/profile.d/conda.sh
    conda activate mindwave
    
    # Process training queue
    python training/process_queue.py >> logs/training.log 2>&1
    
    # Move completed to history
    mv training/queue/pending.json "training/history/$(date +%Y%m%d-%H%M).json"
    
    echo "[$(date)] Training complete" >> logs/training.log
    
    # Notify
    curl -X POST "$NOTIFY_WEBHOOK" \
        -H "Content-Type: application/json" \
        -d '{"message": "🎵 Nightly training complete! New LoRA models available."}'
else
    echo "[$(date)] No pending jobs" >> logs/training.log
fi
