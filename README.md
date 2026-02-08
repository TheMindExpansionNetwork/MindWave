# 🎵 MindWave — Open Source Suno Alternative

**AI Music Generation Platform with Visual Art & LoRA Training**

> Generate the Future

[![GitHub](https://img.shields.io/badge/GitHub-MindWave-6B46C1?style=for-the-badge&logo=github)](https://github.com/TheMindExpansionNetwork/MindWave)

## 🚀 Quick Start

```bash
# Clone the unified platform
git clone https://github.com/TheMindExpansionNetwork/MindWave.git
cd MindWave

# Setup environment
cp .env.example .env
# Edit .env with your configuration

# Start all services
./start-all.sh
```

## ✨ Features

- 🎵 **AI Music Generation** — Full songs up to 10 minutes with ACE-Step 1.5
- 🎨 **Cover Art Generation** — AI-powered artwork via ComfyUI
- 🎛️ **LoRA Fine-tuning** — Train custom models on your datasets
- ⚡ **Autonomous Operation** — Overnight training via cron jobs
- 🌐 **Self-Hosted** — Full privacy, no API keys needed
- 🎭 **MindExpansion Theme** — Dark void aesthetic with neon accents

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         MindWave                            │
├─────────────────────────────────────────────────────────────┤
│  🌐 UI (React)  │  🔌 API (Node/Express)  │  🎨 ComfyUI   │
│                 │                         │    (Art Gen)  │
└─────────────────┴─────────────────────────┴───────────────┘
                          │
                   ┌──────┴──────┐
                   │  ACE-Step   │
                   │  (Music AI) │
                   └─────────────┘
```

## 📁 Repository Structure

```
MindWave/
├── ace-step/          # ACE-Step 1.5 backend
├── ui/                # React web interface
├── server/            # Express API server
├── comfyui/           # ComfyUI workflows
├── api/               # API integrations
├── training/          # LoRA training pipeline
├── datasets/          # Training datasets
├── models/lora/       # Custom trained models
├── scripts/           # Automation scripts
├── outputs/           # Generated content
└── docs/              # Documentation
```

## 🎨 Theming

MindWave uses a dark void theme with neon accents:
- **Primary:** Deep Purple (#6B46C1)
- **Accent:** Neon Cyan (#00FFFF)
- **Background:** Void Black (#0A0A0A)
- **Surface:** Dark Surface (#1A1A1A)

## ⏰ Automation

Overnight cron jobs (via OpenClaw):
- **11 PM** — Start LoRA training
- **2 AM** — Update ComfyUI models
- **4 AM** — Generate test samples
- **6 AM** — Backup all data
- **7 AM** — Send morning report

## 🔗 Sources & Credits

| Component | Repository |
|-----------|-----------|
| Core Model | [ACE-Step-1.5](https://github.com/ace-step/ACE-Step-1.5) → [Our Fork](https://github.com/TheMindExpansionNetwork/ACE-Step-1.5) |
| Web UI | [ace-step-ui](https://github.com/fspecii/ace-step-ui) → [Our Fork](https://github.com/TheMindExpansionNetwork/ace-step-ui) |
| Extended UI | [Deep-Music-Service](https://github.com/UltraDeepAutomation/Deep-Music-Service) → [Our Fork](https://github.com/TheMindExpansionNetwork/Deep-Music-Service) |
| ComfyUI Nodes | [ComfyUI_ACE-Step](https://github.com/billwuhao/ComfyUI_ACE-Step) |

## 📖 Documentation

- [Setup Guide](docs/setup.md) — Complete installation instructions
- [Agentic Plan](docs/AGENTIC_PLAN.md) — Implementation strategy
- [API Reference](docs/api.md) — Backend endpoints

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

MIT — Open source forever

---

**Built with 🔥 by The MindExpansion Network**

*Generate the Future.* 🎵
