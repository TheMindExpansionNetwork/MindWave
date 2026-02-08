#!/bin/bash
# scripts/morning-report.sh - Send daily summary to Mind

cd /home/ubuntu/clawd/skills/MindWave

# Generate report
REPORT="🎵 MindWave Morning Report — $(date '+%Y-%m-%d')

📊 OVERNIGHT STATS:
- New LoRA models: $(ls -1 models/lora/ 2>/dev/null | wc -l)
- Samples generated: $(ls -1 outputs/music/samples/$(date +%Y%m%d)/ 2>/dev/null | wc -l)
- Training jobs completed: $(ls -1 training/history/ 2>/dev/null | grep "$(date +%Y%m%d)" | wc -l)

🎧 RECENT GENERATIONS:
$(ls -1t outputs/music/ 2>/dev/null | head -5 | sed 's/^/- /')

🎯 TODAY'S FOCUS:
- Continue LoRA training
- Generate showcase tracks
- Prepare for launch

Full logs: logs/training.log
"

# Save report
echo "$REPORT" > reports/morning-$(date +%Y%m%d).txt

# Send notification
curl -X POST "$NOTIFY_WEBHOOK" \
    -H "Content-Type: application/json" \
    -d "{\"message\": \"$REPORT\"}"

# Also print to console for OpenClaw
echo "$REPORT"
