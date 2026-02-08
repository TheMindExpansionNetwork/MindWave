#!/bin/bash
# business-controller.sh — Autonomous MindWave business operation

MINDWAVE_DIR="/home/ubuntu/clawd/skills/MindWave"
LOG="$MINDWAVE_DIR/logs/business.log"
DAILY_BUDGET=50  # Max $50/day GPU spend

echo "🏢 MINDWAVE BUSINESS CONTROLLER STARTING" | tee -a "$LOG"
echo "[$(date)] Budget: $${DAILY_BUDGET}/day | Mode: Autonomous" | tee -a "$LOG"

# Cost tracking
track_cost() {
    local cost_file="/tmp/mindwave_daily_cost"
    local today=$(date +%Y%m%d)
    
    if [ ! -f "$cost_file" ] || [ "$(head -1 $cost_file)" != "$today" ]; then
        echo "$today" > "$cost_file"
        echo "0" >> "$cost_file"
    fi
    
    local current_cost=$(tail -1 "$cost_file")
    local new_cost=$(echo "$current_cost + $1" | bc)
    echo "$today" > "$cost_file"
    echo "$new_cost" >> "$cost_file"
    
    echo $new_cost
}

check_budget() {
    local cost_file="/tmp/mindwave_daily_cost"
    local current_cost=$(tail -1 "$cost_file" 2>/dev/null || echo "0")
    
    if (( $(echo "$current_cost > $DAILY_BUDGET" | bc -l) )); then
        echo "[$(date)] 🚨 BUDGET EXHAUSTED: $${current_cost}/$${DAILY_BUDGET}" | tee -a "$LOG"
        /home/ubuntu/clawd/skills/MindWave/scripts/gpu-optimizer.sh stop
        return 1
    fi
    return 0
}

# Phase 1: Generate content for "customers" (simulated demand)
generate_for_market() {
    echo "[$(date)] 🎵 Generating tracks for market..." | tee -a "$LOG"
    
    # Use Modal serverless (cheapest)
    cd "$MINDWAVE_DIR/ace-step"
    
    # Generate 10 sample tracks
    for i in {1..10}; do
        if ! check_budget; then return; fi
        
        local styles=("electronic" "lo-fi" "rock" "ambient" "hip-hop")
        local style=${styles[$RANDOM % ${#styles[@]}]}
        
        modal run modal_serverless.py::generate_music \
            --prompt "${style} music unique track $i" \
            --duration 30 \
            2>> "$LOG"
        
        # Track cost (~$0.03 per 30s generation)
        track_cost 0.03
        
        sleep 5  # Rate limit
    done
    
    echo "[$(date)] ✅ Generated 10 tracks" | tee -a "$LOG"
}

# Phase 2: Train custom models if datasets available
train_custom_models() {
    if [ ! -f "$MINDWAVE_DIR/training/queue/pending.json" ]; then
        echo "[$(date)] ℹ️ No training jobs queued" | tee -a "$LOG"
        return
    fi
    
    echo "[$(date)] 🎓 Starting LoRA training..." | tee -a "$LOG"
    
    # Check budget (training is expensive ~$10-20/hour)
    if ! check_budget; then return; fi
    
    # Use Modal for training (auto-shutdown when done)
    cd "$MINDWAVE_DIR"
    
    modal run ace-step/modal_serverless.py::train_lora \
        --dataset-path "$MINDWAVE_DIR/training/queue/pending.json" \
        --model-name "autonomous-$(date +%s)" \
        2>> "$LOG"
    
    # Track cost (~$15 for full training)
    track_cost 15
    
    # Move to completed
    mv "$MINDWAVE_DIR/training/queue/pending.json" \
       "$MINDWAVE_DIR/training/history/completed-$(date +%Y%m%d).json"
    
    echo "[$(date)] ✅ Training complete" | tee -a "$LOG"
}

# Phase 3: Health and maintenance
maintenance() {
    echo "[$(date)] 🔧 Maintenance check..." | tee -a "$LOG"
    
    # Run health check
    /home/ubuntu/clawd/skills/MindWave/scripts/health-monitor.sh
    
    # Backup
    /home/ubuntu/clawd/skills/MindWave/scripts/backup-mindwave.sh
    
    # Cleanup old files
    find "$MINDWAVE_DIR/outputs" -name "*.mp3" -mtime +7 -delete
    
    echo "[$(date)] ✅ Maintenance complete" | tee -a "$LOG"
}

# Phase 4: Upload to Hugging Face (if token available)
publish_models() {
    if [ -z "$HUGGINGFACE_TOKEN" ]; then
        return
    fi
    
    echo "[$(date)] 📤 Publishing to Hugging Face..." | tee -a "$LOG"
    
    # Upload trained models
    for model in "$MINDWAVE_DIR/models/lora"/*/; do
        if [ -d "$model" ]; then
            model_name=$(basename "$model")
            huggingface-cli upload \
                "Mind-Expansion-Industries/mindwave-lora-${model_name}" \
                "$model" \
                2>> "$LOG" || true
        fi
    done
    
    echo "[$(date)] ✅ Published to HF" | tee -a "$LOG"
}

# Main business loop
main() {
    echo "[$(date)] 🚀 Starting business operations..." | tee -a "$LOG"
    
    # Initial cost check
    check_budget || exit 1
    
    # Business phases
    generate_for_market
    train_custom_models
    maintenance
    publish_models
    
    # Report
    local final_cost=$(tail -1 /tmp/mindwave_daily_cost 2>/dev/null || echo "0")
    echo "[$(date)] 💰 Daily spend: $${final_cost}/$${DAILY_BUDGET}" | tee -a "$LOG"
    
    echo "[$(date)] 🏢 Business operations complete" | tee -a "$LOG"
    
    # Send notification
    curl -X POST "$NOTIFY_WEBHOOK" \
        -H "Content-Type: application/json" \
        -d "{\"message\": \"💰 MindWave overnight: $${final_cost} spent, tracks generated, models trained\"}" \
        2>/dev/null || true
}

# Run main
main
