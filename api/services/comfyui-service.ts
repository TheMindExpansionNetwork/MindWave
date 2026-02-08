// services/comfyui-service.ts - ComfyUI integration for MindWave
import fetch from 'node-fetch';
import * as WebSocket from 'ws';
import { v4 as uuidv4 } from 'uuid';

const COMFYUI_HOST = process.env.COMFYUI_HOST || '192.168.179.111';
const COMFYUI_PORT = process.env.COMFYUI_PORT || '28188';
const COMFYUI_URL = `http://${COMFYUI_HOST}:${COMFYUI_PORT}`;
const COMFYUI_WS = `ws://${COMFYUI_HOST}:${COMFYUI_PORT}`;

interface ComfyUIWorkflow {
  [key: string]: any;
}

export class ComfyUIService {
  private clientId: string;

  constructor() {
    this.clientId = uuidv4();
  }

  /**
   * Generate album cover art from text prompt
   */
  async generateCoverArt(
    prompt: string,
    style: string = 'digital art',
    genre: string = 'electronic'
  ): Promise<string> {
    // Load workflow template
    const workflow = await this.loadWorkflow('cover_art');
    
    // Update prompt node
    const promptNodeId = this.findNodeByType(workflow, 'CLIPTextEncode');
    workflow[promptNodeId].inputs.text = 
      `album cover art, ${genre} music, ${prompt}, ${style}, ` +
      `professional design, high quality, 4k, trending on artstation`;
    
    // Queue the workflow
    const result = await this.queuePrompt(workflow);
    return result.images[0];
  }

  /**
   * Generate lyric video background
   */
  async generateVideoBackground(
    prompt: string,
    duration: number = 30
  ): Promise<string> {
    const workflow = await this.loadWorkflow('video_background');
    
    const promptNodeId = this.findNodeByType(workflow, 'CLIPTextEncode');
    workflow[promptNodeId].inputs.text = 
      `music video background, ${prompt}, ` +
      `dynamic, flowing, rhythmic, seamless loop`;
    
    const result = await this.queuePrompt(workflow);
    return result.video;
  }

  /**
   * Edit existing image (for album art variations)
   */
  async editImage(
    imagePath: string,
    prompt: string
  ): Promise<string> {
    const workflow = await this.loadWorkflow('img2img');
    
    // Set input image
    const loadImageNode = this.findNodeByType(workflow, 'LoadImage');
    workflow[loadImageNode].inputs.image = imagePath;
    
    // Set prompt
    const promptNodeId = this.findNodeByType(workflow, 'CLIPTextEncode');
    workflow[promptNodeId].inputs.text = prompt;
    
    const result = await this.queuePrompt(workflow);
    return result.images[0];
  }

  /**
   * Load workflow JSON from file
   */
  private async loadWorkflow(name: string): Promise<ComfyUIWorkflow> {
    const fs = require('fs').promises;
    const path = require('path');
    
    const workflowPath = path.join(
      __dirname, 
      '../comfyui/workflows', 
      `${name}.json`
    );
    
    const data = await fs.readFile(workflowPath, 'utf-8');
    return JSON.parse(data);
  }

  /**
   * Find node by class type in workflow
   */
  private findNodeByType(
    workflow: ComfyUIWorkflow, 
    type: string
  ): string {
    for (const [id, node] of Object.entries(workflow)) {
      if (node.class_type === type) {
        return id;
      }
    }
    throw new Error(`Node type ${type} not found in workflow`);
  }

  /**
   * Queue prompt and wait for completion
   */
  private async queuePrompt(workflow: ComfyUIWorkflow): Promise<any> {
    // Connect WebSocket
    const ws = new WebSocket(`${COMFYUI_WS}/ws?clientId=${this.clientId}`);
    
    return new Promise((resolve, reject) => {
      let promptId: string;
      
      ws.on('open', async () => {
        try {
          // Queue the prompt
          const response = await fetch(`${COMFYUI_URL}/prompt`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              prompt: workflow,
              client_id: this.clientId
            })
          });
          
          const data = await response.json();
          promptId = data.prompt_id;
        } catch (error) {
          reject(error);
        }
      });
      
      ws.on('message', async (data: any) => {
        const message = JSON.parse(data.toString());
        
        if (message.type === 'executing' && 
            message.data.node === null && 
            message.data.prompt_id === promptId) {
          // Execution complete
          ws.close();
          
          // Get outputs
          const outputs = await this.getOutputs(promptId);
          resolve(outputs);
        }
      });
      
      ws.on('error', reject);
      
      // Timeout after 5 minutes
      setTimeout(() => {
        ws.close();
        reject(new Error('ComfyUI generation timeout'));
      }, 5 * 60 * 1000);
    });
  }

  /**
   * Get outputs from completed prompt
   */
  private async getOutputs(promptId: string): Promise<any> {
    const response = await fetch(`${COMFYUI_URL}/history/${promptId}`);
    const history = await response.json();
    
    const outputs: any = { images: [], video: null };
    
    for (const [nodeId, nodeData] of Object.entries(history[promptId].outputs)) {
      const node: any = nodeData;
      
      if (node.images) {
        for (const image of node.images) {
          outputs.images.push(
            `${COMFYUI_URL}/view?filename=${image.filename}` +
            `&type=${image.type}&subfolder=${image.subfolder || ''}`
          );
        }
      }
    }
    
    return outputs;
  }

  /**
   * Check ComfyUI status
   */
  async status(): Promise<boolean> {
    try {
      const response = await fetch(`${COMFYUI_URL}/system_stats`);
      return response.ok;
    } catch {
      return false;
    }
  }
}

export default new ComfyUIService();
