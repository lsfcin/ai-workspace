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

`Goals → Concept → Stack → Architecture → ↺(Increment → Test+debug → Refactor) → Commit`

- **Concept** decisions → update CONTEXT.md directly. Architectural decisions → `decisions/` ADR.
- **Stack** → record in SPECS.md. **Architecture** → Plan agent.
- **Test+debug**: run tests, read output, iterate — never declare done without verifying.

## General conventions

| Aspect | Convention |
|--------|------------|
| Versioning | Each project has its own git repo (`git init` in project folder) + GitHub remote |
| Branches | `main`, `dev`, `feat/name`, `fix/name` |
| Tests | Required before merging to main |
| Docs | README.md per project, ADRs in `decisions/` |
| Code style | Follow project linter (eslint / ruff) |
| GitHub | URL must be recorded in the Active projects table above |

# LATEST CHANGES
