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
SESSION.md              # Cross-session memory (project root)
context/
  00-contracts/         # Legal scope and contractual constraints
  01-meetings/          # Meeting notes (YYYY-MM-DD-slug.md)
  02-decisions/         # ADRs in JSON format
  03-domain/            # ontology.md (agreed vocabulary) + data-model.yaml (its crystallization)
  04-plan/              # Phases, roadmap, open questions (PM-owned)
  05-product/           # What is being delivered: scope + API contracts (OpenAPI)
  06-technology/        # GUIDELINES.md + guidelines/<SPECIALTY>.md
  07-architecture/      # System diagrams (Mermaid)
  08-design/            # Visual design assets, tokens, mockups
  09-features/          # One folder per feature: feature.md + iteration-*.md + bugfix-*.md
  10-consulting/        # Business analysis and recommendations (optional)
```

## Loading Order (Priority: High → Low)

0. `SESSION.md` (project root) — recent decisions, blockers, and continuity
   notes from previous sessions. Read this first.
1. `contracts` — hard legal/contractual limits. Never violate.
2. `products` — what is being built. Defines scope boundaries.
3. `features` — intended behaviour per feature, in client language.
   Load the folder of the feature you are working on in full.
4. `decisions` — ADRs. Respect existing decisions, flag conflicts.
5. `ontology` — the agreed vocabulary. Use its terms verbatim.
6. `data_model` — crystallization of the ontology into entities and attributes.
7. `technology` — `GUIDELINES.md` + your specialty file under
   `technology/guidelines/` — how we build.
8. `architecture` + `api_contracts` — system structure and API contracts.
9. `meetings` — recent decisions, most recent first.
10. `consulting` — strategic input. Informational, not prescriptive.
11. `plan` — phasing context. Informational, not prescriptive.
12. `design` — Frontend agent only.

## Agent-Specific Loading

**Architect**: loads 0–11 fully before any planning task.
**Backend**: loads 0–8, focusing on `BACKEND.md`, `data_model` and `api_contracts`.
**Frontend**: loads 0–8 + 12, focusing on `FRONTEND.md` and design assets.
**SysOps**: loads 0–8, focusing on architecture diagrams and infra config.
**Cybersec**: loads 0, 1, 4, 5, 6, 8 — contracts in full detail, accepted ADRs,
ontology, data model and architecture.
**QA**: loads 0–8, cross-referencing OpenSpec specs, features and products.

## Interpretation Rules

**SESSION.md**: read all entries, most recent first. Entries tagged with agent identifiers
(e.g. `[BACKEND]`, `[ARCHITECT]`) indicate who left the note. Treat as continuity context,
not as binding decisions — follow up with the relevant spec or ADR for authoritative info.

**ADRs (JSON)**: parse `status` field first.
- `accepted` — binding.
- `proposed` — informational.
- `superseded` — historical context only.

**Ontology**: the explicit agreement on what exists in this domain, written in
natural language: classes, attributes, relations (as verbs) and rules.
- Use its terms exactly. Do not introduce synonyms or new classes.
- A "parked" (aparcado) item is a known unknown. If a task depends on a parked
  term, **stop** and raise it in "Open Questions". Do not resolve it yourself.
- Changing a class, a relation or a rule requires a human conversation and an ADR.
  Adding individuals (rows) does not.

**Data model**: the ontology crystallized into entities, attributes and keys.
If `data_model` and `ontology` disagree, the ontology wins — flag the mismatch
to the Architect. Never add an attribute to the data model that the ontology
does not name.

**Features**: each folder under `features` holds:
- `feature.md` — the *current* intended behaviour, in client language. What, not how.
  Upstream of OpenSpec: the Architect derives specs from it.
- `iteration-YYYY-MM-DD-slug.md` — why the behaviour changed. History.
- `bugfix-YYYY-MM-DD-slug.md` — a reported mismatch between the system and `feature.md`.
Rules:
- If `openspec/specs/` contradicts `feature.md`, `feature.md` wins. Flag it to the
  Architect, who opens a change.
- Frontmatter `entities:` must name classes from the ontology. Unknown or parked
  entities are a blocker, not an assumption.
- Frontmatter `status:` is `proposed` → `specced` → `implemented` → `verified`.
  Only the Architect (`specced`), QA (`implemented`) and `/archive` (`verified`)
  move it forward.

**Meeting notes**: extract decisions and open questions.
Discard discussion noise. If a note contradicts an ADR,
flag the conflict — do not silently pick one.

**Consulting docs**: treat as strategic input. Never promote to
decision status without explicit human confirmation.

**Missing files**: note it in your "Assumptions" section and
proceed. Do not halt execution. Exception: a missing or parked
ontology term that the task depends on is a blocker (see above).

**Conflicts between sources**: surface in "Open Questions".
Apply the higher-priority source in the meantime.

## OpenSpec Integration

Before starting any task, also read:
- `openspec/specs/` — current behavioral source of truth.
- `openspec/changes/<active-change>/` — work in progress.

Active changes take precedence over main specs for in-flight work.
If no active change exists for the requested task, flag this to
the Architect agent before proceeding.
