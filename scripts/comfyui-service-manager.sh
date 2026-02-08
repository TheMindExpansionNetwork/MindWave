#!/bin/bash
# comfyui-service-manager.sh - Manage ComfyUI service for MindWave

COMFYUI_HOST="${COMFYUI_HOST:-192.168.179.111}"
COMFYUI_PORT="${COMFYUI_PORT:-28188}"
COMFYUI_DIR="${COMFYUI_DIR:-/home/ubuntu/ComfyUI}"
LOG_FILE="/home/ubuntu/clawd/skills/MindWave/logs/comfyui.log"

mkdir -p /home/ubuntu/clawd/skills/MindWave/logs

status() {
    if curl -s "http://${COMFYUI_HOST}:${COMFYUI_PORT}/system_stats" > /dev/null 2>&1; then
        echo "✅ ComfyUI is running on ${COMFYUI_HOST}:${COMFYUI_PORT}"
        return 0
    else
        echo "❌ ComfyUI is not running"
        return 1
    fi
}

start() {
    if status > /dev/null 2>&1; then
        echo "ComfyUI already running"
        return 0
    fi
    
    echo "🚀 Starting ComfyUI..."
    cd "$COMFYUI_DIR" || exit 1
    
    nohup python main.py \
        --listen "$COMFYUI_HOST" \
        --port "$COMFYUI_PORT" \
        >> "$LOG_FILE" 2>&1 &
    
    # Wait for startup
    for i in {1..30}; do
        if status > /dev/null 2>&1; then
            echo "✅ ComfyUI started successfully"
            return 0
        fi
        sleep 2
    done
    
    echo "❌ Failed to start ComfyUI"
    return 1
}

stop() {
    echo "🛑 Stopping ComfyUI..."
    pkill -f "python main.py" || true
    sleep 2
    
    if ! status > /dev/null 2>&1; then
        echo "✅ ComfyUI stopped"
        return 0
    else
        echo "⚠️  ComfyUI still running, forcing kill..."
        pkill -9 -f "python main.py" || true
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
        echo "[$(date)] ComfyUI down - restarting..." >> "$LOG_FILE"
        start
        
        # Notify
        curl -X POST "$NOTIFY_WEBHOOK" \
            -H "Content-Type: application/json" \
            -d '{"message": "⚠️ ComfyUI was down - auto-restarted"}' \
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
