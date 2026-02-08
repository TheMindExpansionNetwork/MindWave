// tailwind.config.ts - MindWave Dark Theme
import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './src/**/*.{js,ts,jsx,tsx}',
    './index.html',
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        // MindWave Brand Colors
        mindwave: {
          void: '#0A0A0A',
          dark: '#121212',
          surface: '#1A1A1A',
          primary: '#6B46C1',      // Deep Purple
          accent: '#00FFFF',       // Neon Cyan
          glow: '#8B5CF6',         // Purple Glow
          text: '#FFFFFF',
          muted: '#A0A0A0',
          border: '#2A2A2A',
        },
        // Semantic colors
        success: '#10B981',
        warning: '#F59E0B',
        error: '#EF4444',
        info: '#3B82F6',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['Fira Code', 'monospace'],
        display: ['Space Grotesk', 'sans-serif'],
      },
      animation: {
        'pulse-glow': 'pulse-glow 2s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'waveform': 'waveform 1s ease-in-out infinite',
        'glitch': 'glitch 1s linear infinite',
      },
      keyframes: {
        'pulse-glow': {
          '0%, 100%': { opacity: '1', boxShadow: '0 0 20px rgba(107, 70, 193, 0.5)' },
          '50%': { opacity: '.5', boxShadow: '0 0 40px rgba(107, 70, 193, 0.8)' },
        },
        waveform: {
          '0%, 100%': { transform: 'scaleY(0.5)' },
          '50%': { transform: 'scaleY(1)' },
        },
        glitch: {
          '0%, 100%': { transform: 'translate(0)' },
          '20%': { transform: 'translate(-2px, 2px)' },
          '40%': { transform: 'translate(-2px, -2px)' },
          '60%': { transform: 'translate(2px, 2px)' },
          '80%': { transform: 'translate(2px, -2px)' },
        },
      },
      backgroundImage: {
        'gradient-void': 'linear-gradient(180deg, #0A0A0A 0%, #121212 100%)',
        'gradient-glow': 'radial-gradient(ellipse at center, rgba(107, 70, 193, 0.15) 0%, transparent 70%)',
      },
    },
  },
  plugins: [],
};

export default config;
