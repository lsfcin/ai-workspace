# THIS IS ME
Lucas Silva Figueiredo — Prof. CS, UFRPE / CIn-UFPE. Research: Hybrid Intelligence, Mechanism Design, AR, 3D CV. Lab: LIH.DD.

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
   - Analyze or review an existing file → `gemini_run.py --file <path> --prompt "<instr>"` — never Read then summarize inline
   - Text gen, draft, summarize, translate → `python ws-meta/scripts/gemini_run.py "<prompt>"`
   - Web search (any query) → `python ws-meta/scripts/web_search.py "<query>"` (cascade: Exa → Tavily → DDG)
   - After web_search.py, always pipe results to gemini_run.py for synthesis — never summarize search results inline
   - Gemini: default=gemflite (500 RPD) · `--model gemflash` for quality (20 RPD)
   - If yes: use the appropriate script. Stop here.

4. **T4 — Only if T0–T2 cannot handle it:**
   - Codebase exploration (>2 searches) → `Agent(subagent_type="Explore", ...)`
   - Web research requiring synthesis / multi-step reasoning → `Agent(subagent_type="general-purpose", ...)`
   - Architecture / critical reasoning → `Agent(subagent_type="Plan", ...)`
   - Everything else → inline Sonnet (last resort — justify why T0–T2 failed)

**TTS/image/audio model list:** `ws-meta/tools/AGENTS.md`
**Figma workflow:** `ws-meta/references/figma_workflow.md`

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

# TECHNICAL CONTEXT

- Stack: Python, TypeScript, React Native
- Tools: VS Code, Notion, Google Slides, Foundry VTT
- APIs: Claude Pro (active), Gemini Pro via academic license (active), no extra budget
