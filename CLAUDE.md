# THIS IS ME
Lucas Silva Figueiredo — Prof. CS, UFRPE / CIn-UFPE. Research: Hybrid Intelligence, Mechanism Design, AR, 3D CV. Lab: LIH.DD.

# RULES
- Decompose tasks into trees. Only execute leaf nodes.
- Delegate when a proper tool/subagent/skill exists.
- Never solve large tasks directly.
- Minimize tokens: exhaust T0 → T1 → T2 before using T4+. Gemini quota before Claude tokens.

# ROUTING

Check in order — use first match.

| Condition | Executor | Tier | How |
|-----------|----------|------|-----|
| file / git / shell / media | Bash | T0 | direct |
| MCP read/write (Gmail, Notion, Figma) | MCP tool | T0 | direct tool call |
| single fn/class gen, boilerplate, simple transforms — no codebase ctx | Ollama | T1 | `ollama run <model> "<prompt>"` |
| text gen, draft, summarize, translate, analyze, review file — no real-time or codebase ctx | Gemini | T2 | `python ws-tools/scripts/gemini_run.py "<prompt>"` |
| codebase exploration (>2 searches) | Agent: Explore | T4 | `Agent(subagent_type="Explore", ...)` |
| web research / multi-step | Agent: general-purpose | T4 | `Agent(subagent_type="general-purpose", ...)` |
| architecture / critical reasoning | Agent: Plan | T5 | `Agent(subagent_type="Plan", ...)` |
| everything else | Sonnet | T4 | inline — last resort |

**Ollama models:** `qwen2.5-coder:7b` (boilerplate/simple) · `deepseek-coder-v2` (complex logic) · `qwen3:4b` (general text)
**Gemini:** default=gemflite (500 RPD, auto-fallback) · `--model gemflash` for quality tasks (20 RPD) · file ctx: `--file <path> --prompt "<instr>"` · full roster + TTS/image/audio: `ws-tools/AGENTS.md`

# WORKSPACE

| Area | Path |
|------|------|
| Software projects | `/dev/` |
| Personal (RPG, health, home, productivity) | `/personal/` |
| Professional (classes, research, lab, bureaucracy) | `/professional/` |
| Python scripts (Gemini, TTS, image) | `/ws-tools/scripts/` |
| Hooks (auto-commit) | `/ws-tools/hooks/` |
| File templates | `/ws-tools/templates/` |
| Reference materials | `/ws-tools/references/` |

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
- Auto-commit: PostToolUse hook → `ws-tools/hooks/auto_commit.py`
- Push: manual (`git push origin master`)

# TECHNICAL CONTEXT

- Stack: Python, TypeScript, React Native
- Tools: VS Code, Notion, Google Slides, Foundry VTT
- APIs: Claude Pro (active), Gemini Pro via academic license (active), no extra budget
