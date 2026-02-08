#!/bin/bash
# start-all.sh - Start entire MindWave platform

set -e

MINDWAVE_DIR="/home/ubuntu/clawd/skills/MindWave"
COMFYUI_DIR="/home/ubuntu/ComfyUI"
LOG_DIR="$MINDWAVE_DIR/logs"

mkdir -p "$LOG_DIR"

echo "🎵 Starting MindWave Platform..."
echo "================================"

# Check GPU
if command -v nvidia-smi &> /dev/null; then
    echo "✅ GPU detected:"
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
else
    echo "⚠️  No GPU detected - performance will be limited"
fi

# Start ACE-Step API
echo ""
echo "🎹 Starting ACE-Step API..."
cd "$MINDWAVE_DIR/ace-step"
source /home/ubuntu/.conda/etc/profile.d/conda.sh 2>/dev/null || true
conda activate mindwave 2>/dev/null || source venv/bin/activate 2>/dev/null || true

if ! curl -s http://localhost:8001/health > /dev/null 2>&1; then
    nohup uv run acestep-api --port 8001 > "$LOG_DIR/ace-step.log" 2>&1 &
    echo "   Waiting for API to start..."
    for i in {1..60}; do
        if curl -s http://localhost:8001/health > /dev/null 2>&1; then
            echo "   ✅ ACE-Step API running on port 8001"
            break
        fi
        sleep 2
    done
else
    echo "   ✅ ACE-Step API already running"
fi

# Start ComfyUI
echo ""
echo "🎨 Starting ComfyUI..."
cd "$COMFYUI_DIR"

if ! curl -s http://192.168.179.111:28188/system_stats > /dev/null 2>&1; then
    nohup python main.py --listen 192.168.179.111 --port 28188 > "$LOG_DIR/comfyui.log" 2>&1 &
    echo "   Waiting for ComfyUI to start..."
    for i in {1..60}; do
        if curl -s http://192.168.179.111:28188/system_stats > /dev/null 2>&1; then
            echo "   ✅ ComfyUI running on 192.168.179.111:28188"
            break
        fi
        sleep 2
    done
else
    echo "   ✅ ComfyUI already running"
fi

# Start MindWave UI
echo ""
echo "🌐 Starting MindWave UI..."
cd "$MINDWAVE_DIR/ui"

if [ -f "server/package.json" ]; then
    cd server
    if ! lsof -i :3000 > /dev/null 2>&1; then
        nohup npm start > "$LOG_DIR/ui-server.log" 2>&1 &
        echo "   ✅ UI Server starting on port 3000"
    else
        echo "   ✅ UI Server already running"
    fi
    cd ..
fi

# Summary
echo ""
echo "================================"
echo "🚀 MindWave Platform Started!"
echo "================================"
echo ""
echo "Services:"
echo "  🎹 ACE-Step API:    http://localhost:8001"
echo "  🎨 ComfyUI:         http://192.168.179.111:28188"
echo "  🌐 MindWave UI:     http://localhost:3000"
echo ""
echo "Logs: $LOG_DIR"
echo ""
echo "To stop: ./stop-all.sh"
echo ""
