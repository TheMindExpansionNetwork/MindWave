# MindWave Setup Guide

Complete setup instructions for the MindWave AI music platform.

## Prerequisites

- Ubuntu 20.04+ or similar Linux
- NVIDIA GPU with CUDA support (RTX 3090 or better recommended)
- 32GB+ RAM
- 100GB+ free disk space
- Python 3.10+
- Node.js 18+
- Git

## Quick Start

### 1. Clone the Repository

```bash
cd /home/ubuntu/clawd/skills
git clone https://github.com/TheMindExpansionNetwork/MindWave.git
cd MindWave
```

### 2. Setup ACE-Step Backend

```bash
# Create environment
conda create -n mindwave python=3.10
conda activate mindwave

# Install ACE-Step
cd ace-step
pip install -e .

# Download models
acestep-download

# Test API
uv run acestep-api --port 8001
```

### 3. Setup ComfyUI

```bash
# Install ComfyUI
cd /home/ubuntu
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI
pip install -r requirements.txt

# Start ComfyUI
python main.py --listen 192.168.179.111 --port 28188
```

### 4. Setup UI

```bash
cd /home/ubuntu/clawd/skills/MindWave/ui

# Install dependencies
npm install
cd server && npm install && cd ..

# Configure environment
cp server/.env.example server/.env
# Edit server/.env with your settings

# Start UI
./start-all.sh
```

### 5. Configure OpenClaw Automation

```bash
# Add cron jobs
openclaw cron add openclaw-cron-complete.yaml

# Or manually add each job
openclaw cron add mindwave-health-check --schedule "*/5 * * * *" \
  --command "/home/ubuntu/clawd/skills/MindWave/scripts/health-monitor.sh"
```

## Environment Variables

Create `.env` file in project root:

```bash
# ComfyUI Configuration
COMFYUI_HOST=192.168.179.111
COMFYUI_PORT=28188

# ACE-Step Configuration
ACE_STEP_PORT=8001
ACE_STEP_MODEL_PATH=/models/ace-step-1.5

# Notification Webhook (optional)
NOTIFY_WEBHOOK=https://hooks.slack.com/services/YOUR/WEBHOOK/URL

# Cloud Backup (optional)
CLOUD_BACKUP_BUCKET=your-s3-bucket
AWS_ACCESS_KEY_ID=your-key
AWS_SECRET_ACCESS_KEY=your-secret
```

## Service Management

### Manual Control

```bash
# Start all services
./scripts/ace-step-service-manager.sh start
./scripts/comfyui-service-manager.sh start

# Check status
./scripts/ace-step-service-manager.sh status
./scripts/comfyui-service-manager.sh status

# Restart
./scripts/ace-step-service-manager.sh restart
./scripts/comfyui-service-manager.sh restart

# Stop
./scripts/ace-step-service-manager.sh stop
./scripts/comfyui-service-manager.sh stop
```

### Automated Health Monitoring

Health checks run every 5 minutes via cron:
- Checks if ACE-Step API is responding
- Checks if ComfyUI is running
- Restarts services if down
- Monitors disk space
- Alerts on issues

## LoRA Training

### Prepare Dataset

```bash
# Create dataset
mkdir -p datasets/my-genre/audio
mkdir -p datasets/my-genre/metadata

# Add audio files (8+ songs recommended)
cp /path/to/songs/*.mp3 datasets/my-genre/audio/

# Create metadata
cat > datasets/my-genre/metadata/info.json <<EOF
{
  "name": "My Genre",
  "description": "Custom genre training data",
  "files": [
    {"filename": "song1.mp3", "tags": ["electronic", "upbeat"]},
    {"filename": "song2.mp3", "tags": ["electronic", "melodic"]}
  ]
}
EOF
```

### Start Training

```bash
# Queue training job
cat > training/queue/pending.json <<EOF
{
  "job_id": "my-genre-v1",
  "dataset": "my-genre",
  "epochs": 100,
  "learning_rate": 1e-4,
  "priority": "high"
}
EOF

# Training starts automatically at 11 PM via cron
# Or start manually:
python training/process_queue.py
```

## Troubleshooting

### ACE-Step won't start
```bash
# Check logs
tail -f logs/ace-step.log

# Verify CUDA
nvidia-smi

# Check port availability
lsof -i :8001
```

### ComfyUI connection failed
```bash
# Check if ComfyUI is running
curl http://192.168.179.111:28188/system_stats

# Restart ComfyUI
./scripts/comfyui-service-manager.sh restart
```

### Out of memory
```bash
# Clear GPU cache
nvidia-smi --gpu-reset

# Reduce batch size in training config
# Or use CPU offloading
```

## API Endpoints

### Music Generation
```bash
POST /api/generate/music
{
  "prompt": "Electronic music with deep bass",
  "duration": 30,
  "lora": "my-genre-v1"  // optional
}
```

### Cover Art Generation
```bash
POST /api/generate/cover
{
  "prompt": "Abstract waves, neon colors",
  "style": "digital art",
  "genre": "electronic"
}
```

### Full Package
```bash
POST /api/generate/full
{
  "prompt": "Electronic music with deep bass",
  "duration": 30,
  "cover_style": "digital art"
}
```

## Security

- Run services behind firewall
- Use strong passwords for admin panels
- Keep API keys in environment variables
- Regular backups via cron
- Monitor logs for suspicious activity

## Updates

```bash
# Update from upstream
cd ace-step && ./update-from-upstream.sh
cd ../ui && git pull upstream main

# Update MindWave
cd /home/ubuntu/clawd/skills/MindWave
git pull origin main
```

## Support

- GitHub Issues: https://github.com/TheMindExpansionNetwork/MindWave/issues
- Documentation: https://github.com/TheMindExpansionNetwork/MindWave/tree/main/docs
- Discord: [MindExpansion Network](https://discord.gg/mindexpansion)

---

**Ready to generate the future!** 🎵🔥
