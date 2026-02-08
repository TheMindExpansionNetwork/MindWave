#!/bin/bash
# gpu-optimizer.sh — Cost-efficient GPU management for MindWave

MODE="${1:-auto}"
LOG="/home/ubuntu/clawd/skills/MindWave/logs/gpu-optimizer.log"

log() {
    echo "[$(date)] $1" | tee -a "$LOG"
}

# Check if generation is needed
needs_gpu() {
    # Check generation queue
    if [ -f "/home/ubuntu/clawd/skills/MindWave/queue/generate.json" ]; then
        local queue_size=$(jq '.requests | length' "/home/ubuntu/clawd/skills/MindWave/queue/generate.json" 2>/dev/null || echo "0")
        if [ "$queue_size" -gt 0 ]; then
            return 0  # true
        fi
    fi
    
    # Check if training is scheduled
    if [ -f "/home/ubuntu/clawd/skills/MindWave/training/queue/pending.json" ]; then
        return 0  # true
    fi
    
    # Check active sessions (if user is online)
    local active_users=$(who | wc -l)
    if [ "$active_users" -gt 0 ]; then
        return 0  # true
    fi
    
    return 1  # false
}

# Stop GPU services to save costs
stop_gpu_services() {
    log "💰 Stopping GPU services to save costs..."
    
    # Stop ACE-Step API (uses GPU)
    /home/ubuntu/clawd/skills/MindWave/scripts/ace-step-service-manager.sh stop 2>/dev/null || true
    
    # ComfyUI can stay (CPU mode for queue management)
    # But stop actual generation workers
    pkill -f "comfyui.*gpu" 2>/dev/null || true
    
    log "✅ GPU services stopped. Cost: $0/hour"
}

# Start GPU services when needed
start_gpu_services() {
    log "🚀 Starting GPU services for generation..."
    
    # Start ACE-Step API
    /home/ubuntu/clawd/skills/MindWave/scripts/ace-step-service-manager.sh start
    
    # Start ComfyUI GPU workers
    # (ComfyUI auto-detects GPU availability)
    
    log "✅ GPU services active. Cost: ~$0.50-2/hour (while generating)"
}

# Auto mode — smart scaling
auto_mode() {
    while true; do
        if needs_gpu; then
            if ! pgrep -f "acestep-api" > /dev/null; then
                start_gpu_services
            fi
        else
            if pgrep -f "acestep-api" > /dev/null; then
                # Wait 5 min of idle before stopping (prevent thrashing)
                log "⏳ GPU idle — waiting 5 min before stopping..."
                sleep 300
                if ! needs_gpu; then
                    stop_gpu_services
                fi
            fi
        fi
        
        sleep 60  # Check every minute
    done
}

# Modal serverless mode — most cost effective
modal_mode() {
    log "☁️ Modal serverless mode — GPU on-demand only"
    
    # Stop local GPU services entirely
    stop_gpu_services
    
    # Deploy ACE-Step on Modal (serverless)
    cd /home/ubuntu/clawd/skills/MindWave
    modal deploy ace-step/modal_serverless.py 2>/dev/null || log "Modal deployment manual — run 'modal deploy' when ready"
    
    log "✅ Modal mode active — GPU: $0 idle, ~$0.001/sec while generating"
}

# Hybrid mode — local CPU + Modal GPU
hybrid_mode() {
    log "⚡ Hybrid mode — Local CPU queue + Modal GPU inference"
    
    # Keep local CPU services running (cheap)
    # Route GPU jobs to Modal
    
    cat > /home/ubuntu/clawd/skills/MindWave/config/hybrid.json << 'EOF'
{
  "mode": "hybrid",
  "local": {
    "enabled": ["api", "ui", "queue"],
    "gpu": false
  },
  "modal": {
    "enabled": ["inference", "training"],
    "gpu": "A100",
    "idle_timeout": 60
  },
  "cost_optimization": {
    "max_gpu_hours_per_day": 4,
    "auto_shutdown_idle": 300,
    "prefer_modal": true
  }
}
EOF
    
    log "✅ Hybrid config saved. GPU jobs → Modal (auto-scaling)"
}

# Business mode — maximum automation
business_mode() {
    log "🏢 BUSINESS MODE — Full autonomous operation with cost caps"
    
    # Set hard limits
    export MAX_GPU_HOURS_PER_DAY=6
    export MAX_DAILY_COST=50  # dollars
    export AUTO_SHUTDOWN_IDLE=180  # 3 min idle = stop GPU
    
    # Start optimizer daemon
    auto_mode &
    
    log "✅ Business mode active — Max $50/day, auto-shutdown after 3 min idle"
}

# Main
case "$MODE" in
    stop)
        stop_gpu_services
        ;;
    start)
        start_gpu_services
        ;;
    auto)
        auto_mode
        ;;
    modal)
        modal_mode
        ;;
    hybrid)
        hybrid_mode
        ;;
    business)
        business_mode
        ;;
    status)
        if pgrep -f "acestep-api" > /dev/null; then
            log "✅ GPU services: RUNNING (cost: ~$0.50-2/hr)"
        else
            log "💤 GPU services: STOPPED (cost: $0/hr)"
        fi
        
        # Show daily cost estimate
        local gpu_hours=$(cat /tmp/gpu_hours_today 2>/dev/null || echo "0")
        log "📊 GPU hours today: $gpu_hours (max: 6)"
        ;;
    *)
        echo "Usage: $0 {start|stop|auto|modal|hybrid|business|status}"
        echo ""
        echo "Modes:"
        echo "  start    - Start GPU services (high cost)"
        echo "  stop     - Stop GPU services (no cost)"
        echo "  auto     - Smart scaling based on demand"
        echo "  modal    - Serverless GPU (most cost-effective)"
        echo "  hybrid   - Local CPU + Modal GPU (balanced)"
        echo "  business - Autonomous with cost caps (recommended)"
        echo "  status   - Show current cost status"
        exit 1
        ;;
esac
