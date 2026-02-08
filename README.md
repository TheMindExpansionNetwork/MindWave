# 🎵 MindWave — Open Source Suno Alternative

**AI Music Generation Platform with Visual Art Integration**

MindWave combines ACE-Step 1.5's state-of-the-art music generation with ComfyUI-powered cover art, LoRA fine-tuning, and autonomous overnight training pipelines.

## 🚀 Quick Start

```bash
# 1. Clone the unified platform
git clone https://github.com/TheMindExpansionNetwork/MindWave.git
cd MindWave

# 2. Setup backend
conda env create -f environment.yml
conda activate mindwave
python -m acestep install

# 3. Setup UI
cd ui
npm install
npm run dev

# 4. Start ComfyUI (in separate terminal)
cd comfyui
python main.py

# 5. Start API server
cd api
python server.py
```

## 📁 Repository Structure

```
MindWave/
├── ace-step/          # Core music generation (ACE-Step 1.5)
├── ui/                # React web interface
├── comfyui/           # ComfyUI workflows for art generation
├── api/               # Unified FastAPI backend
├── training/          # LoRA fine-tuning pipeline
├── datasets/          # Training datasets
├── models/lora/       # Custom trained models
├── scripts/           # Automation scripts
├── outputs/           # Generated content
└── docs/              # Documentation
```

## 🎯 Features

- **🎵 Music Generation** — Full songs up to 10 minutes
- **🎨 Cover Art** — AI-generated album artwork
- **🎛️ LoRA Training** — Fine-tune on custom datasets
- **⚡ Autonomous** — Overnight training via cron jobs
- **🌐 Self-Hosted** — No API keys, full privacy
- **🎭 Themed** — MindExpansion aesthetic

## 🔗 Sources

| Component | Original | Fork |
|-----------|----------|------|
| Core Model | [ace-step/ACE-Step-1.5](https://github.com/ace-step/ACE-Step-1.5) | [TheMindExpansionNetwork/ACE-Step-1.5](https://github.com/TheMindExpansionNetwork/ACE-Step-1.5) |
| Web UI | [fspecii/ace-step-ui](https://github.com/fspecii/ace-step-ui) | [TheMindExpansionNetwork/ace-step-ui](https://github.com/TheMindExpansionNetwork/ace-step-ui) |
| Extended UI | [UltraDeepAutomation/Deep-Music-Service](https://github.com/UltraDeepAutomation/Deep-Music-Service) | [TheMindExpansionNetwork/Deep-Music-Service](https://github.com/TheMindExpansionNetwork/Deep-Music-Service) |

## 📖 Documentation

- [Agentic Implementation Plan](docs/AGENTIC_PLAN.md) — Complete build strategy
- [Setup Guide](docs/setup.md) — Installation instructions
- [API Reference](docs/api.md) — Backend endpoints
- [Training Guide](docs/training-guide.md) — LoRA fine-tuning

## ⏰ Automation

Overnight cron jobs:
- **11 PM** — Start LoRA training
- **2 AM** — Update ComfyUI models
- **4 AM** — Generate test samples
- **6 AM** — Backup datasets
- **7 AM** — Send morning report

## 🎨 Theming

- Dark void theme by default
- MindExpansion purple accents
- Waveform visualizations
- Glitch effect loading states

## 🚀 Deployment

```bash
# Production build
./scripts/deploy.sh

# Or manual
docker-compose up -d
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Submit PR

## 📄 License

MIT — Open source forever

---

**Generate the Future** 🎵🔥
