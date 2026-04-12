# Clief Notes — Method Reference

Material from the "The Foundation" course by Jake Van Clief (Clief Notes / Skool).
Theoretical foundation for the architecture of this AI Workspace.

## When to consult

- When creating or reviewing CONTEXT.md, SPECS.md, routing tables
- When evaluating whether the folder structure follows the principles
- When explaining the system to others

## Files by priority

### Essential (read first)

| File | Key content |
|------|-------------|
| 3.1 The Full Walkthrough | 3-layer system: Map (CLAUDE.md) → Rooms (CONTEXT.md) → Tools. Routing table. Naming conventions |
| 3.2 Customizing for Your Use Case | 3 real examples (content creator, freelancer, developer). How to adapt layers to your work |
| 3.3 Common Mistakes | 7 errors: long ctx, no routing table, too many workspaces, ctx about AI instead of work, stale ctx, flat folder, over-engineering |
| 1.3 How to Structure Any Prompt | 5-part framework: Identity, Task, Context, Constraints, Output Format. Chunking |

### Useful (consult when relevant)

| File | Key content |
|------|-------------|
| 1.2 Your First Folder | Minimal setup: 3 files (CLAUDE.md, CONTEXT.md, REFERENCES.md) |
| 4.2 Claude Code in Practice | Loop Read→Think→Write→Check→Adjust. Desktop vs Code. Token math (200K ctx, ~2K/doc) |
| 2.5 Clawdbot (Moltbot) | Orchestration vs intelligence. 60/30/10 framework. Where value lives |
| 2.6 Video as Code | Pipeline: spec.md → style guide → component registry → Remotion → CapCut. Separation of concerns applied to creative work. Constraints improve output |
| 2.2 One Line of Python | 7 layers: Python→bytecode→C→assembly→machine code→hardware→electrons. Every layer started unreliable and became reliable via architecture. AI = next layer |

### Theoretical context (consult for deep understanding)

| File | Key content |
|------|-------------|
| 2.1 Video Text Guide | Map of the 6-video series. Throughline: AI = next layer of 70+ years of stack |
| 2.3 How a 1953 Word Game Explains AI Memory | Context window = working memory. In LLMs, code and data are the same thing. Why prompt injection works and why structured ctx matters |
| 2.4 The Ladder That Explains Every AI Failure | Value lives above what was commoditized. Don't automate at the wrong layer |
| 1.1 What You Need | Setup: Claude account (Free/Pro/Max), VS Code or Cursor, Node.js for Claude Code |

### PDFs not mapped in this context file

2.7, 4.1, 4.3, 4.4, 4.5, 5.1

## Key extracted principles

1. CLAUDE.md is a map, not an encyclopedia. Fits on 1 screen
2. Routing table: task → folder → what to read. Eliminates ambiguity
3. CONTEXT.md describes the work, not the AI's personality (80/20)
4. Start minimal, grow through use. 15 min on v1
5. Treat ctx files as working notes — edit constantly
6. More than 8-10 files at the same level → needs subfolders
7. If unsure whether something deserves its own workspace → it doesn't. Use a subfolder
8. AI is a component (10%), value lies in the surrounding architecture (90%)
9. Spec is the leverage point — the more precise, the better the output
10. Constraints don't limit, they focus. Style guide and component registry are constraints encoded as files
