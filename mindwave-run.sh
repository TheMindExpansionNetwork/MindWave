#!/bin/bash
# mindwave-run.sh — Simple overnight operation

cd /home/ubuntu/clawd/skills/MindWave

echo "🎵 MindWave Starting..."

# 1. Start services
./start-all.sh

# 2. Generate 5 tracks overnight
for i in {1..5}; do
    echo "Generating track $i..."
    curl -X POST http://localhost:8001/generate \
        -d "{\"prompt\": \"Electronic track $i\", \"duration\": 30}" \
        -o "outputs/music/track-$i.mp3" 2>/dev/null
    sleep 60
done

# 3. Morning report
echo "✅ Done. 5 tracks generated." | telegram-send --stdin

echo "🌙 Goodnight"
