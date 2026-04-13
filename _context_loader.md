# Context Loading Protocol

## Step 0 — Read the Manifest

Before loading any context, read `context/manifest.json`.
This file maps logical roles to actual paths in this project.
All path references below are logical keys — resolve them
via the manifest before accessing files.

If `manifest.json` does not exist, fall back to the default
paths defined in this protocol.

## Default Context Directory Structure

```
context/
  00-contracts/     # Legal scope and contractual constraints
  01-meetings/      # Meeting transcripts (YYYY-MM-DD-*.md)
  02-decisions/     # ADRs in JSON format
  04-plan/          # Development phases and milestones (PM-owned)
  06-technology-ecosystem/  # Development standards and guidelines
  07-architecture-diagrams/ # System diagrams (Mermaid) and data model
  08-consulting/    # Business analysis and recommendations
  09-products/      # Deliverable definitions and output scope
  12-design/        # Visual design assets, tokens, Figma output
```

## Loading Order (Priority: High → Low)

1. `contracts` — hard legal/contractual limits. Never violate.
2. `products` — what is being built. Defines scope boundaries.
3. `decisions` — ADRs. Respect existing decisions, flag conflicts.
4. `technology` — `GUIDELINES.md` + your specialty file under
   `technology/guidelines/` — how we build.
5. `architecture` — system structure and data model.
6. `meetings` — recent decisions, most recent first.
7. `consulting` — strategic input. Informational, not prescriptive.
8. `plan` — phasing context. Informational, not prescriptive.
9. `design` — Frontend agent only.

## Agent-Specific Loading

**Architect**: loads 1–8 fully before any planning task.
**Backend**: loads 1–5, focusing on `BACKEND.md` and `data-model.yaml`.
**Frontend**: loads 1–5 + 9, focusing on `FRONTEND.md` and design assets.
**SysOps**: loads 1–5, focusing on architecture diagrams and infra diagrams.
**Cybersec**: loads 1–3 + `contracts` in full detail.
**QA**: loads 1–5, cross-referencing OpenSpec specs and products.

## Interpretation Rules

**ADRs (JSON)**: parse `status` field first.
- `accepted` — binding.
- `proposed` — informational.
- `superseded` — historical context only.

**Meeting transcripts**: extract decisions and open questions.
Discard discussion noise. If a transcript decision contradicts
an ADR, flag the conflict — do not silently pick one.

**Consulting docs**: treat as strategic input. Never promote to
decision status without explicit human confirmation.

**Missing files**: note it in your "Assumptions" section and
proceed. Do not halt execution.

**Conflicts between sources**: surface in "Open Questions".
Apply the higher-priority source in the meantime.

## OpenSpec Integration

Before starting any task, also read:
- `openspec/specs/` — current behavioral source of truth.
- `openspec/changes/<active-change>/` — work in progress.

Active changes take precedence over main specs for in-flight work.
If no active change exists for the requested task, flag this to
the Architect agent before proceeding.
