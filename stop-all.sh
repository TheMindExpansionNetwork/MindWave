#!/bin/bash
# stop-all.sh - Stop all MindWave services

echo "🛑 Stopping MindWave Platform..."

# Stop ACE-Step API
pkill -f "acestep-api" || true

# Stop ComfyUI
pkill -f "python main.py" || true

# Stop UI
pkill -f "npm start" || true

sleep 2

echo "✅ All services stopped"
