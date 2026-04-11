# Dev — Software Projects

Personal and lab software projects. Primary stack: Python, TypeScript, React Native.

## Active projects

| Project | Status | Short description | GitHub |
|---------|--------|-------------------|--------|
| AppTime | In dev | Android app — screen time monitoring with floating overlay | — |
| Voti | Planning | Citizen ↔ politician vote matching | — |
| NeoEduc | In dev (team) | AI-powered pedagogical platform, 3D avatar, whitelabel | — |
| Email Agent | Planning | Agent to read, summarize and prioritize emails | — |

## Development lifecycle

All projects follow this flow in order — do not skip phases:

1. **Goals** — define problem, target user, success criteria
2. **Concept** — discuss approaches, trade-offs, decisions (no code yet)
3. **Stack** — choose platforms, libs, APIs → record in SPECS.md
4. **Architecture** — plan high-level modules and data flow → Plan agent
5. **Minimal increment** — implement the smallest testable slice
6. **Verify** — auto-test + verbose debug; check autonomously before reporting done
7. **Refactor** — clean up, remove debug verbosity
8. **Commit** — conventional commit, push when stable

## General conventions

| Aspect | Convention |
|--------|------------|
| Versioning | Git, conventional commits |
| Branches | `main`, `dev`, `feat/name`, `fix/name` |
| Tests | Required before merging to main |
| Docs | README.md per project, ADRs in `decisions/` |
| Code style | Follow project linter (eslint / ruff) |
| GitHub | Each project under `dev/` must have its own GitHub repo — URL recorded in this table |

# LATEST CHANGES
