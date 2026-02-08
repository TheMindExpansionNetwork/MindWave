# modal_serverless.py — Serverless ACE-Step on Modal (zero idle cost)
import modal

# Modal app
app = modal.App("mindwave-inference")

# Image with ACE-Step and all dependencies
image = (
    modal.Image.debian_slim(python_version="3.10")
    .apt_install("git", "wget", "ffmpeg", "libsndfile1")
    .pip_install(
        "torch==2.1.0",
        "torchaudio",
        "transformers",
        "accelerate",
        "diffusers",
        "soundfile",
        "librosa",
        "numpy",
        "scipy"
    )
    .run_commands(
        "cd /root && git clone https://github.com/TheMindExpansionNetwork/ACE-Step-1.5.git acestep",
        "cd /root/acestep && pip install -e ."
    )
)

# Volume for model caching (persistent)
models_volume = modal.Volume.from_name("mindwave-models", create_if_missing=True)

@app.function(
    image=image,
    gpu="A100",
    memory=32768,
    container_idle_timeout=60,  # Keep warm for 60 sec after request
    volumes={"/models": models_volume}
)
def generate_music(
    prompt: str,
    duration: int = 30,
    style: str = "electronic",
    lyrics: str = None
) -> dict:
    """Generate music on-demand — GPU only active during generation"""
    
    import torch
    from acestep import ACEStepPipeline
    import tempfile
    import base64
    
    # Load model (cached on volume after first run)
    pipe = ACEStepPipeline.from_pretrained(
        "/models/ace-step-1.5",
        torch_dtype=torch.float16
    ).to("cuda")
    
    # Generate
    result = pipe(
        prompt=prompt,
        duration=duration,
        style=style,
        lyrics=lyrics,
        num_inference_steps=50
    )
    
    # Save to temp file
    with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as f:
        result.audio.export(f.name, format="mp3")
        
        # Read and encode
        with open(f.name, "rb") as audio_file:
            audio_data = base64.b64encode(audio_file.read()).decode()
    
    return {
        "audio_base64": audio_data,
        "duration": duration,
        "prompt": prompt,
        "cost": "~$0.001/sec of audio"
    }

@app.function(
    image=image,
    gpu="A100",
    memory=65536,
    timeout=3600,  # 1 hour max for training
    volumes={"/models": models_volume}
)
def train_lora(
    dataset_path: str,
    model_name: str,
    epochs: int = 100
) -> dict:
    """Train LoRA on Modal — only pay for training time"""
    
    from acestep.training import LoRATrainer
    import json
    
    trainer = LoRATrainer(
        base_model="/models/ace-step-1.5",
        output_dir=f"/models/lora/{model_name}"
    )
    
    # Load dataset
    with open(dataset_path) as f:
        dataset = json.load(f)
    
    # Train
    trainer.train(
        dataset=dataset,
        epochs=epochs,
        learning_rate=1e-4
    )
    
    return {
        "model_name": model_name,
        "path": f"/models/lora/{model_name}",
        "epochs": epochs,
        "cost": f"~${epochs * 0.02} (estimated)"
    }

# FastAPI endpoint for integration
@app.function(image=image)
@modal.fastapi_endpoint(method="POST")
def api_generate(request: dict):
    """HTTP endpoint for UI integration"""
    result = generate_music.remote(
        prompt=request.get("prompt"),
        duration=request.get("duration", 30),
        style=request.get("style", "electronic")
    )
    return result

@app.local_entrypoint()
def main():
    """Test the deployment"""
    print("🎵 Testing MindWave serverless generation...")
    
    result = generate_music.remote(
        prompt="Electronic music with deep bass",
        duration=10
    )
    
    print(f"✅ Generated {result['duration']}s of music")
    print(f"💰 Cost: {result['cost']}")
