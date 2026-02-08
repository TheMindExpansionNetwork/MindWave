#!/bin/bash
# ace-step-service-manager.sh - Manage ACE-Step API service

ACE_STEP_DIR="${ACE_STEP_DIR:-/home/ubuntu/clawd/skills/ACE-Step-1.5}"
API_PORT="${ACE_STEP_PORT:-8001}"
LOG_FILE="/home/ubuntu/clawd/skills/MindWave/logs/ace-step.log"

mkdir -p /home/ubuntu/clawd/skills/MindWave/logs

status() {
    if curl -s "http://localhost:${API_PORT}/health" > /dev/null 2>&1; then
        echo "✅ ACE-Step API is running on port ${API_PORT}"
        return 0
    else
        echo "❌ ACE-Step API is not running"
        return 1
    fi
}

start() {
    if status > /dev/null 2>&1; then
        echo "ACE-Step API already running"
        return 0
    fi
    
    echo "🚀 Starting ACE-Step API..."
    cd "$ACE_STEP_DIR" || exit 1
    
    # Activate environment
    source /home/ubuntu/.conda/etc/profile.d/conda.sh 2>/dev/null || true
    conda activate ace-step 2>/dev/null || source venv/bin/activate 2>/dev/null || true
    
    nohup uv run acestep-api --port "$API_PORT" \
        >> "$LOG_FILE" 2>&1 &
    
    # Wait for startup
    for i in {1..60}; do
        if status > /dev/null 2>&1; then
            echo "✅ ACE-Step API started successfully"
            return 0
        fi
        sleep 2
    done
    
    echo "❌ Failed to start ACE-Step API"
    return 1
}

stop() {
    echo "🛑 Stopping ACE-Step API..."
    pkill -f "acestep-api" || true
    sleep 2
    
    if ! status > /dev/null 2>&1; then
        echo "✅ ACE-Step API stopped"
        return 0
    else
        echo "⚠️  Forcing kill..."
        pkill -9 -f "acestep-api" || true
        return 0
    fi
}

restart() {
    stop
    sleep 3
    start
}

health_check() {
    if ! status > /dev/null 2>&1; then
        echo "[$(date)] ACE-Step API down - restarting..." >> "$LOG_FILE"
        start
        
        # Notify
        curl -X POST "$NOTIFY_WEBHOOK" \
            -H "Content-Type: application/json" \
            -d '{"message": "⚠️ ACE-Step API was down - auto-restarted"}' \
            > /dev/null 2>&1 || true
    fi
}

case "$1" in
    status)
        status
        ;;
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    health)
        health_check
        ;;
    *)
        echo "Usage: $0 {status|start|stop|restart|health}"
        exit 1
        ;;
esac
