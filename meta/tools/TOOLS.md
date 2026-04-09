# Ferramentas — Referência Técnica

> Lido para implementação de scripts, não para routing. Para routing → `CONTEXT.md`.

## Hardware

> RTX 3050 6GB Laptop GPU · 16GB RAM  
> Ollama: modelos ≤7B em GPU; 8-9B com RAM offload (mais lento)

## CLIs disponíveis

| Ferramenta | Status | Propósito |
|------------|--------|-----------|
| pandoc | ✅ | md ↔ docx ↔ html ↔ pdf |
| ffmpeg | ✅ | Áudio/vídeo |
| jq | ✅ | JSON |
| imagemagick | ❌ | Imagem batch |
| rclone | ❌ | Cloud sync |

## MCPs ativos

| Serviço | Propósito |
|---------|-----------|
| Notion | CRUD páginas |
| Gmail | Leitura e triagem |
| Figma | Design, diagramas |

## Scripts Gemini

| Script | Função | Agente |
|--------|--------|--------|
| `meta/scripts/gemini_run.py` | Texto (Gemflite padrão, fallback automático) | Gemflite→Gemflash |
| `meta/scripts/gemini_tts.py` | Texto → WAV | Gemvoice |
| `meta/scripts/gemini_image.py` | Texto → PNG | Gemvision→Gemart |
| `meta/scripts/imagen_run.py` | Imagen 4 (requer billing) | Imago |
| `meta/scripts/gemini_live_skeleton.py` | WebSocket skeleton | Gemwave/Gemlive |
