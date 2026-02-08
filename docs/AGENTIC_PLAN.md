# 🎵 MINDWAVE — Open Source Suno Alternative
## Agentic Implementation Plan

**Vision:** Build a fully open-source AI music generation platform that rivals Suno/Udio, with integrated visual art generation, model fine-tuning capabilities, and autonomous overnight training pipelines.

---

## 🎯 Goals

1. **Core Music Generation** — ACE-Step 1.5 backend with custom web UI
2. **Visual Integration** — ComfyUI-powered cover art generation
3. **Model Training** — LoRA fine-tuning on custom datasets
4. **Autonomous Operation** — Cron jobs for overnight training/upkeep
5. **Open Source Stack** — Fully self-hostable, no API keys required
6. **Themed Branding** — MindExpansion aesthetic throughout

---

## 📦 Repository Inventory

### Forked Repositories

| Repo | Location | Purpose | Fork URL |
|------|----------|---------|----------|
| **ACE-Step-1.5** | `/home/ubuntu/clawd/skills/ACE-Step-1.5` | Core music generation model | [TheMindExpansionNetwork/ACE-Step-1.5](https://github.com/TheMindExpansionNetwork/ACE-Step-1.5) |
| **ace-step-ui** | `/home/ubuntu/clawd/skills/ace-step-ui` | React web interface | [TheMindExpansionNetwork/ace-step-ui](https://github.com/TheMindExpansionNetwork/ace-step-ui) |
| **Deep-Music-Service** | `/home/ubuntu/clawd/skills/Deep-Music-Service` | Extended UI/service layer | [TheMindExpansionNetwork/Deep-Music-Service](https://github.com/TheMindExpansionNetwork/Deep-Music-Service) |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    MINDWAVE PLATFORM                        │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Web UI     │  │  API Server  │  │  ComfyUI     │      │
│  │  (React)     │◄─┤   (FastAPI)  │◄─┤  (Art Gen)   │      │
│  └──────────────┘  └──────┬───────┘  └──────────────┘      │
│                           │                                 │
│                    ┌──────┴───────┐                        │
│                    │  ACE-Step    │                        │
│                    │   Model      │                        │
│                    └──────────────┘                        │
│                           │                                 │
│              ┌────────────┼────────────┐                   │
│              ▼            ▼            ▼                   │
│        ┌─────────┐  ┌─────────┐  ┌─────────┐              │
│        │  LoRA   │  │ Training│  │  Model  │              │
│        │ Modules │  │ Pipeline│  │  Cache  │              │
│        └─────────┘  └─────────┘  └─────────┘              │
└─────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    │   OpenClaw Agent  │
                    │  (Cron/Automation)│
                    └───────────────────┘
```

---

## 🎨 Theming & Branding

### Brand Identity
- **Name:** MindWave
- **Tagline:** "Generate the Future"
- **Colors:** 
  - Primary: Deep Purple (#6B46C1)
  - Accent: Neon Cyan (#00FFFF)
  - Dark: Void Black (#0A0A0A)
- **Logo:** Waveform + Neural Network hybrid
- **Vibe:** Underground rave meets AI research lab

### UI Modifications
1. Replace all "ACE-Step" branding with "MindWave"
2. Add MindExpansion logo to header
3. Implement dark theme by default
4. Add particle/wave animations
5. Custom loading states with glitch effects

---

## 🔧 Integration Steps

### Phase 1: Core Integration (Hours 1-4)

#### 1.1 Merge UI Components
```bash
cd /home/ubuntu/clawd/skills/ace-step-ui

# Install dependencies
npm install

# Link to ACE-Step backend
npm run setup-backend --path=/home/ubuntu/clawd/skills/ACE-Step-1.5
```

#### 1.2 Theme Customization
```bash
# Update branding
find . -type f -name "*.tsx" -exec sed -i 's/ACE-Step/MindWave/g' {} +
find . -type f -name "*.ts" -exec sed -i 's/ACE-Step/MindWave/g' {} +

# Apply dark theme
cp themes/mindwave-dark.css src/styles/theme.css
```

#### 1.3 ComfyUI Integration
```typescript
// services/comfyui.ts
export class ComfyUIService {
  async generateCoverArt(prompt: string, style: string): Promise<string> {
    const workflow = await loadWorkflow('cover_art.json');
    workflow.prompt = `${prompt}, ${style}, album cover art, music themed`;
    
    const result = await fetch('http://localhost:8188/prompt', {
      method: 'POST',
      body: JSON.stringify({ prompt: workflow })
    });
    
    return result.images[0];
  }
}
```

### Phase 2: Backend Integration (Hours 5-8)

#### 2.1 Unified API Server
```python
# server/unified_api.py
from fastapi import FastAPI
from acestep import ACEStepModel
from comfyui_client import ComfyUIClient

app = FastAPI(title="MindWave API")
model = ACEStepModel()
comfy = ComfyUIClient()

@app.post("/generate/music")
async def generate_music(prompt: str, duration: int = 30):
    """Generate music with ACE-Step"""
    audio = model.generate(prompt, duration=duration)
    return {"audio_url": audio.url, "duration": duration}

@app.post("/generate/cover")
async def generate_cover(prompt: str, style: str = "digital art"):
    """Generate album art with ComfyUI"""
    image = comfy.generate(prompt, style)
    return {"image_url": image.url}

@app.post("/generate/full")
async def generate_full_package(prompt: str):
    """Generate music + cover art together"""
    music = await generate_music(prompt)
    cover = await generate_cover(prompt)
    return {**music, **cover}
```

#### 2.2 Model Management
```python
# server/model_manager.py
class ModelManager:
    def __init__(self):
        self.base_model = None
        self.lora_models = {}
        
    def load_base_model(self):
        """Load ACE-Step 1.5 base model"""
        from acestep import load_model
        self.base_model = load_model("ace-step-1.5")
        
    def load_lora(self, name: str, path: str):
        """Load LoRA fine-tune"""
        self.lora_models[name] = self.base_model.load_lora(path)
        
    def generate_with_lora(self, prompt: str, lora_name: str = None):
        """Generate with optional LoRA"""
        if lora_name and lora_name in self.lora_models:
            return self.base_model.generate(prompt, lora=self.lora_models[lora_name])
        return self.base_model.generate(prompt)
```

### Phase 3: Training Pipeline (Hours 9-12)

#### 3.1 LoRA Training Setup
```python
# training/lora_trainer.py
class LoRATrainer:
    def __init__(self, config_path: str):
        self.config = load_config(config_path)
        
    def prepare_dataset(self, audio_files: list, labels: list):
        """Prepare training data"""
        dataset = []
        for audio, label in zip(audio_files, labels):
            features = extract_features(audio)
            dataset.append({"features": features, "label": label})
        return dataset
        
    def train(self, dataset, output_name: str, epochs: int = 100):
        """Train LoRA model"""
        from acestep.training import LoRATrainer as ACETrainer
        
        trainer = ACETrainer(
            base_model="ace-step-1.5",
            output_dir=f"models/lora/{output_name}"
        )
        
        trainer.train(
            dataset=dataset,
            epochs=epochs,
            learning_rate=1e-4,
            batch_size=4
        )
        
        return f"models/lora/{output_name}/final_model.safetensors"
```

#### 3.2 Dataset Management
```python
# training/dataset_manager.py
class DatasetManager:
    def __init__(self, base_path: str = "datasets"):
        self.base_path = base_path
        
    def create_dataset(self, name: str, genre: str):
        """Create new dataset structure"""
        path = f"{self.base_path}/{name}"
        os.makedirs(f"{path}/audio", exist_ok=True)
        os.makedirs(f"{path}/metadata", exist_ok=True)
        
        # Create metadata template
        metadata = {
            "name": name,
            "genre": genre,
            "created_at": datetime.now().isoformat(),
            "files": []
        }
        
        with open(f"{path}/metadata/dataset.json", "w") as f:
            json.dump(metadata, f, indent=2)
            
    def add_to_dataset(self, dataset_name: str, audio_file: str, tags: list):
        """Add audio file to dataset"""
        # Copy audio
        dest = f"{self.base_path}/{dataset_name}/audio/{os.path.basename(audio_file)}"
        shutil.copy(audio_file, dest)
        
        # Update metadata
        metadata_path = f"{self.base_path}/{dataset_name}/metadata/dataset.json"
        with open(metadata_path, "r") as f:
            metadata = json.load(f)
            
        metadata["files"].append({
            "filename": os.path.basename(audio_file),
            "tags": tags,
            "added_at": datetime.now().isoformat()
        })
        
        with open(metadata_path, "w") as f:
            json.dump(metadata, f, indent=2)
```

---

## ⏰ Cron Jobs (Overnight Automation)

### Nightly Training Schedule
```bash
# crontab -e

# 11 PM: Start model training
0 23 * * * /home/ubuntu/clawd/skills/MindWave/scripts/nightly-training.sh

# 2 AM: Run ComfyUI model updates
0 2 * * * /home/ubuntu/clawd/skills/MindWave/scripts/update-comfyui-models.sh

# 4 AM: Generate sample outputs for testing
0 4 * * * /home/ubuntu/clawd/skills/MindWave/scripts/generate-samples.sh

# 6 AM: Sync datasets to backup
0 6 * * * /home/ubuntu/clawd/skills/MindWave/scripts/backup-datasets.sh

# 7 AM: Send morning report to Mind
0 7 * * * /home/ubuntu/clawd/skills/MindWave/scripts/morning-report.sh
```

### Nightly Training Script
```bash
#!/bin/bash
# scripts/nightly-training.sh

cd /home/ubuntu/clawd/skills/MindWave

# Load environment
source .env

# Check for pending training jobs
if [ -f "training/queue/pending.json" ]; then
    echo "$(date): Starting nightly training..." >> logs/training.log
    
    # Process each pending job
    python training/process_queue.py
    
    # Move completed to history
    mv training/queue/pending.json training/history/$(date +%Y%m%d).json
    
    echo "$(date): Training complete" >> logs/training.log
fi

# Send notification
openclaw notify "Nightly training complete. Check models/lora/ for new models."
```

### Sample Generation Script
```bash
#!/bin/bash
# scripts/generate-samples.sh

cd /home/ubuntu/clawd/skills/MindWave

# Generate test samples with each LoRA
for model in models/lora/*/; do
    model_name=$(basename "$model")
    
    python -c "
from server.model_manager import ModelManager
mgr = ModelManager()
mgr.load_base_model()
mgr.load_lora('$model_name', '$model')

# Generate 3 samples
for i in range(3):
    result = mgr.generate_with_lora(
        'Electronic music with deep bass and ethereal synths',
        '$model_name'
    )
    print(f'Generated: {result}')
" >> logs/samples.log
done
```

---

## 🔌 ComfyUI Integration

### Workflow Setup
```json
{
  "cover_art_workflow": {
    "nodes": {
      "prompt": {
        "class_type": "CLIPTextEncode",
        "inputs": {
          "text": "album cover art, {genre}, {style}, music themed, high quality, 4k"
        }
      },
      "model": {
        "class_type": "CheckpointLoaderSimple",
        "inputs": {
          "ckpt_name": "SDXL/music-diffusion-v1.safetensors"
        }
      },
      "sampler": {
        "class_type": "KSampler",
        "inputs": {
          "seed": 42,
          "steps": 30,
          "cfg": 7.0,
          "sampler_name": "dpmpp_2m",
          "scheduler": "karras"
        }
      }
    }
  }
}
```

### ComfyUI Bridge Service
```python
# services/comfyui_bridge.py
import websocket
import json
import uuid

class ComfyUIBridge:
    def __init__(self, server_address="127.0.0.1:8188"):
        self.server_address = server_address
        self.client_id = str(uuid.uuid4())
        
    def generate_cover(self, prompt: str, genre: str = "electronic"):
        """Generate album cover via ComfyUI"""
        # Load workflow template
        workflow = self.load_workflow("cover_art.json")
        
        # Update prompt
        workflow["prompt"]["inputs"]["text"] = (
            f"album cover art, {genre} music, {prompt}, "
            f"professional design, high quality, 4k"
        )
        
        # Queue prompt
        ws = websocket.WebSocket()
        ws.connect(f"ws://{self.server_address}/ws?clientId={self.client_id}")
        
        prompt_data = {
            "prompt": workflow,
            "client_id": self.client_id
        }
        
        response = requests.post(
            f"http://{self.server_address}/prompt",
            json=prompt_data
        )
        
        # Wait for completion
        prompt_id = response.json()["prompt_id"]
        return self.wait_for_completion(ws, prompt_id)
        
    def wait_for_completion(self, ws, prompt_id):
        """Wait for generation to complete"""
        while True:
            msg = ws.recv()
            data = json.loads(msg)
            
            if data["type"] == "executing" and data["data"]["node"] is None:
                if data["data"]["prompt_id"] == prompt_id:
                    # Get output images
                    return self.get_outputs(prompt_id)
                    
    def get_outputs(self, prompt_id):
        """Retrieve generated images"""
        response = requests.get(
            f"http://{self.server_address}/history/{prompt_id}"
        )
        history = response.json()
        
        outputs = []
        for node_id, node_data in history[prompt_id]["outputs"].items():
            if "images" in node_data:
                for image in node_data["images"]:
                    outputs.append({
                        "filename": image["filename"],
                        "url": f"http://{self.server_address}/view?filename={image['filename']}"
                    })
        return outputs
```

---

## 🚀 Deployment Plan

### Pre-Launch Checklist
- [ ] ACE-Step backend tested and optimized
- [ ] UI themed with MindWave branding
- [ ] ComfyUI bridge functional
- [ ] LoRA training pipeline tested
- [ ] Cron jobs configured and tested
- [ ] Documentation complete
- [ ] Demo tracks generated

### Launch Day (Tomorrow)
**Morning (8-10 AM):**
1. Final UI polish
2. Generate showcase tracks
3. Test ComfyUI integration
4. Verify cron jobs

**Noon (12 PM):**
1. Deploy to VPS/RunPod
2. Configure domain (optional)
3. Public announcement

**Evening (6 PM):**
1. Monitor usage
2. Collect feedback
3. Plan v1.1 features

---

## 📁 Project Structure

```
/home/ubuntu/clawd/skills/MindWave/
├── ace-step/                    # ACE-Step 1.5 backend
│   ├── models/                  # Base models
│   └── training/                # Training scripts
├── ui/                          # React web interface
│   ├── src/
│   ├── public/
│   └── package.json
├── comfyui/                     # ComfyUI workflows
│   ├── workflows/
│   │   ├── cover_art.json
│   │   └── lyric_video.json
│   └── models/
├── api/                         # Unified API server
│   ├── server.py
│   ├── model_manager.py
│   └── comfyui_bridge.py
├── training/                    # Training pipeline
│   ├── lora_trainer.py
│   ├── dataset_manager.py
│   └── queue/
│       ├── pending.json
│       └── history/
├── datasets/                    # Training datasets
│   └── [genre-name]/
│       ├── audio/
│       └── metadata/
├── models/                      # Generated models
│   └── lora/
│       └── [model-name]/
├── scripts/                     # Automation scripts
│   ├── nightly-training.sh
│   ├── generate-samples.sh
│   ├── update-comfyui-models.sh
│   ├── backup-datasets.sh
│   └── morning-report.sh
├── outputs/                     # Generated content
│   ├── music/
│   ├── covers/
│   └── videos/
├── docs/                        # Documentation
│   ├── setup.md
│   ├── api.md
│   └── training-guide.md
└── README.md                    # Main project README
```

---

## 🛠️ OpenClaw Agent Configuration

### Agent Tasks
```yaml
# agent-config.yaml
agent:
  name: MindWave-Builder
  schedule:
    - time: "23:00"
      task: "Start nightly training"
    - time: "02:00"
      task: "Update ComfyUI models"
    - time: "04:00"
      task: "Generate test samples"
    - time: "07:00"
      task: "Send morning report"
      
  triggers:
    - event: "new_audio_uploaded"
      action: "add_to_dataset"
    - event: "training_completed"
      action: "notify_user"
    - event: "model_generated"
      action: "test_model"
```

### Cron Job Integration
```bash
# ~/.openclaw/cron/mindwave-nightly.yaml
job:
  name: "MindWave Nightly Build"
  schedule: "0 23 * * *"
  command: |
    cd /home/ubuntu/clawd/skills/MindWave && \
    openclaw run --skill mindwave-training --mode autonomous
  environment:
    CUDA_VISIBLE_DEVICES: "0"
    ACE_STEP_MODEL_PATH: "/models/ace-step-1.5"
```

---

## 📝 Next Steps (Immediate Action Items)

### Today (Next 4 Hours)
1. [ ] **Merge UI repos** — Combine ace-step-ui + Deep-Music-Service
2. [ ] **Apply MindWave theming** — Dark theme + branding
3. [ ] **Test ACE-Step backend** — Verify model loads correctly
4. [ ] **Setup ComfyUI bridge** — Test cover art generation

### Tonight (Overnight)
1. [ ] **Start LoRA training** — First custom model training run
2. [ ] **Generate sample library** — 50+ demo tracks
3. [ ] **Backup datasets** — Sync to cloud storage
4. [ ] **Morning report** — Summary of night's work

### Tomorrow (Launch Day)
1. [ ] **Final testing** — End-to-end workflow
2. [ ] **Deploy** — Push to production
3. [ ] **Announce** — Share with community

---

## 🔗 Repository Links

| Component | Repository | Local Path |
|-----------|-----------|------------|
| Core Model | [ACE-Step-1.5](https://github.com/TheMindExpansionNetwork/ACE-Step-1.5) | `/home/ubuntu/clawd/skills/ACE-Step-1.5` |
| Web UI | [ace-step-ui](https://github.com/TheMindExpansionNetwork/ace-step-ui) | `/home/ubuntu/clawd/skills/ace-step-ui` |
| Extended UI | [Deep-Music-Service](https://github.com/TheMindExpansionNetwork/Deep-Music-Service) | `/home/ubuntu/clawd/skills/Deep-Music-Service` |
| Unified Platform | **MindWave** (create new) | `/home/ubuntu/clawd/skills/MindWave` |

---

## 🎉 Success Metrics

- [ ] Generate 10+ tracks on first night
- [ ] Train 1+ LoRA model
- [ ] Create 20+ cover artworks
- [ ] Zero downtime overnight
- [ ] Morning report delivered

**Let's build the future of AI music.** 🎵🔥
