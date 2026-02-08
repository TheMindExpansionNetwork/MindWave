#!/bin/bash
# scripts/generate-samples.sh - Generate test samples overnight

cd /home/ubuntu/clawd/skills/MindWave

mkdir -p outputs/music/samples/$(date +%Y%m%d)

echo "[$(date)] Generating samples..." >> logs/samples.log

# Generate with base model
python -c "
from api.model_manager import ModelManager
import time

mgr = ModelManager()
mgr.load_base_model()

prompts = [
    'Electronic music with deep bass and ethereal synths',
    'Lo-fi hip hop beats for studying',
    'Energetic drum and bass track',
    'Ambient soundscape for meditation',
    'Rock anthem with powerful guitars'
]

for i, prompt in enumerate(prompts):
    result = mgr.generate(prompt, duration=30)
    print(f'Generated {i+1}/{len(prompts)}: {result}')
    time.sleep(5)
" >> logs/samples.log 2>&1

# Generate with each LoRA model
for model_path in models/lora/*/; do
    if [ -d "$model_path" ]; then
        model_name=$(basename "$model_path")
        echo "[$(date)] Testing LoRA: $model_name" >> logs/samples.log
        
        python -c "
from api.model_manager import ModelManager
mgr = ModelManager()
mgr.load_base_model()
mgr.load_lora('$model_name', '$model_path')
result = mgr.generate_with_lora('Test track', '$model_name')
print(f'Generated with $model_name: {result}')
" >> logs/samples.log 2>&1
    fi
done

echo "[$(date)] Sample generation complete" >> logs/samples.log
