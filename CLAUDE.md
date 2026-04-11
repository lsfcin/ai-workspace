# THIS IS ME
Lucas Silva Figueiredo — Prof. CS, UFRPE / CIn-UFPE. Research: Hybrid Intelligence, Mechanism Design, AR, 3D CV. Lab: LIH.DD.

# RULES
- Decompose tasks into trees. Only execute leaf nodes.
- Delegate when a proper tool/subagent/skill exists.
- Never solve large tasks directly.
- Minimize tokens: exhaust T0 → T1 → T2 before using T4+. Gemini quota before Claude tokens.

# ROUTING

**MANDATORY: walk this checklist before every response. Do not skip steps.**

1. **T0 — Can Bash or an MCP tool handle it entirely?**
   - File, git, shell, media → `Bash`
   - Gmail, Notion, Figma read/write → MCP tool
   - If yes: use it. Stop here.

2. **T1 — Is this isolated code gen with no codebase context needed?**
   - Single fn/class, boilerplate, simple transform → `ollama run <model> "<prompt>"`
   - Models: `qwen2.5-coder:7b` (simple) · `deepseek-coder-v2` (complex logic) · `qwen3:4b` (general text)
   - If yes: use Ollama. Stop here.

3. **T2 — Is this analysis/review/text with no real-time or codebase context?**
   - Analyze or review an existing file → `gemini_run.py --file <path> --prompt "<instr>"`
   - Text gen, draft, summarize, translate → `python ws-meta/scripts/gemini_run.py "<prompt>"`
   - Gemini: default=gemflite (500 RPD) · `--model gemflash` for quality (20 RPD)
   - If yes: use Gemini. Stop here.

4. **T4 — Only if T0–T2 cannot handle it:**
   - Codebase exploration (>2 searches) → `Agent(subagent_type="Explore", ...)`
   - Web research / multi-step → `Agent(subagent_type="general-purpose", ...)`
   - Architecture / critical reasoning → `Agent(subagent_type="Plan", ...)`
   - Everything else → inline Sonnet (last resort — justify why T0–T2 failed)

**Full tool roster + TTS/image/audio:** `ws-meta/tools/AGENTS.md`

# WORKSPACE

| Area | Path |
|------|------|
| Software projects | `/dev/` |
| Personal (RPG, health, home, productivity) | `/personal/` |
| Professional (classes, research, lab, bureaucracy) | `/professional/` |
| Python scripts (Gemini, TTS, image) | `/ws-meta/scripts/` |
| Hooks (auto-commit) | `/ws-meta/hooks/` |
| File templates | `/ws-meta/templates/` |
| Reference materials | `/ws-meta/references/` |
| Agent roster + tool status | `/ws-meta/tools/` |

# PROTOCOLS

**Context:** read CONTEXT.md root → leaf. SPECS.md only for technical impl.
**Consistency:** before changing stack/deps — cross-check SPECS.md. Conflict → present, await confirmation.
**Context update:** at end of any response that changes project state, append one line to `# LATEST CHANGES` in the relevant CONTEXT.md. Silent — no proposal, no confirmation. Triggers: decision taken, phase advanced, dep/constraint changed. Non-triggers: brainstorming without conclusion, mechanical tasks.

# GLOBAL RULES

- Language: English. Portuguese only when explicitly requested.
- Format: Markdown. LaTeX only for math/formal science.
- Never fabricate academic references.

# VERSIONING

- Repo: https://github.com/lsfcin/ai-workspace (MIT)
- Auto-commit: PostToolUse hook → `ws-meta/hooks/auto_commit.py`
- Push: manual (`git push origin master`)

# TECHNICAL CONTEXT

- Stack: Python, TypeScript, React Native
- Tools: VS Code, Notion, Google Slides, Foundry VTT
- APIs: Claude Pro (active), Gemini Pro via academic license (active), no extra budget
- Health check: `python ws-meta/scripts/health_check.py` → `ws-meta/tools/tools_status.md`
- Local hardware: Dell G15, 16GB RAM, Mobile RTX 3050 with 7.8GB VRAM
