# the-bench

Centralized prompt library for Claude Code agents. Versioned, composable,
and installed into projects with a single script.

## Philosophy

- **Separation of concerns** — each agent has a defined scope and does not
  operate outside it.
- **Hierarchy** — strategic agents (Architect) define. Technical agents
  (Backend, Frontend, SysOps, Cybersec, QA) execute.
- **Composability** — all agents inherit shared base behavior via `_base.md`
  and a common context protocol via `_context_loader.md`.
- **Portability** — projects map their own folder structure to logical roles
  via `context/manifest.json`, decoupling agents from any specific layout.
- **Stop, don't guess** — the context chain is explicit
  (`ontology → data model → API contract → feature → spec → code`). When a
  link is missing or parked, agents raise it instead of filling it in.

## Repository Structure

```
the-bench/
  agents/
    _base.md              # Shared behavior: output format, hierarchy, standards
    _context_loader.md    # Protocol for reading project context
    architect.md
    backend.md
    frontend.md
    sysops.md
    cybersec.md
    qa.md
  commands/
    feature.md
    bugfix.md
    spec.md
    review.md
    security-audit.md
  templates/
    manifest.json.template
    environments.json.template
    SESSION.md.template
    features/
      feature.md          # intended behaviour, client language
      iteration.md        # why a feature changed
      bugfix.md           # a mismatch between system and feature.md
  install.sh
```

## How Agents Compose

Every agent file imports the two base files at the top:

```markdown
@_base.md
@_context_loader.md

# Architect Agent
...
```

Claude Code resolves `@path` imports at runtime, so changes to `_base.md`
propagate to all agents immediately with no manual sync needed.

## Project Integration

### Install

Run this from your project root:

```bash
curl -fsSL https://raw.githubusercontent.com/Blancowicz/the-bench/main/install.sh | bash
```

The script will:
- Install agents → `.claude/agents/` (always overwritten)
- Install commands → `.claude/commands/` (always overwritten)
- Install feature templates → `.claude/templates/` (always overwritten)
- Copy config templates if not present → `context/manifest.json`, `infra/environments.json`, `SESSION.md`
- Update `.gitignore` with the right entries

Use `--project /path/to/project` to install somewhere other than the current directory.

### Upgrade

To pull the latest agents and commands without touching your config files:

```bash
curl -fsSL https://raw.githubusercontent.com/Blancowicz/the-bench/main/install.sh | bash -s -- --upgrade
```

Your `manifest.json`, `environments.json`, and `SESSION.md` are never overwritten on upgrade.

### Manual install (alternative)

If you prefer not to pipe curl to bash, clone and run directly:

```bash
git clone git@github.com:Blancowicz/the-bench.git /tmp/the-bench
/tmp/the-bench/install.sh
rm -rf /tmp/the-bench
```

### Post-install steps

After installing, edit the three config files the script created:

1. `context/manifest.json` — map logical keys to your project's context folder structure
2. `infra/environments.json` — add your AWS profiles and Terraform version
3. `SESSION.md` — update the initial date entry

Then open Claude Code and run `/agents` to verify agents are loaded.

### Reference agents from CLAUDE.md

In your project root `CLAUDE.md`:

```markdown
@.claude/agents/architect.md
```

In sublayers (e.g. `apps/api/CLAUDE.md`):

```markdown
@../../.claude/agents/backend.md
```

## Context Manifest

Each project has a `context/manifest.json` that maps logical keys to
actual folder paths. Agents never hardcode folder names.

```json
{
  "version": "1.1",
  "paths": {
    "contracts":     "00-contracts",
    "meetings":      "01-meetings",
    "decisions":     "02-decisions",
    "ontology":      "03-domain/ontology.md",
    "data_model":    "03-domain/data-model.yaml",
    "plan":          "04-plan",
    "products":      "05-product",
    "api_contracts": "05-product/api",
    "technology":    "06-technology",
    "architecture":  "07-architecture",
    "design":        "08-design",
    "features":      "09-features",
    "consulting":    "10-consulting",
    "infra_config":  "infra/environments.json"
  },
  "disabled": [],
  "notes": {
    "consulting": "Strategic input only. Do not treat as decisions.",
    "plan": "Informational. Use for phase validation only."
  }
}
```

If `manifest.json` is absent, agents fall back to the default paths
documented in `_context_loader.md`. Existing projects with a different
layout only need to edit the paths; `ontology`, `features`, `api_contracts`
and `consulting` are optional and agents note their absence as an assumption.

## Ontology and Data Model

Two files, two jobs:

- `ontology` — the explicit agreement on what exists in the domain, written in
  natural language: classes, attributes, relations as verbs, rules, and a
  **parked** section for terms that are known but not yet agreed.
- `data_model` — the ontology crystallized into entities, attributes and keys.

Agents use ontology terms verbatim. A parked term that a task depends on is a
blocker: the Architect stops and asks instead of inventing a definition. Changing
a class, relation or rule needs a human conversation and an ADR; adding rows
does not.

## Features

`features/<slug>/` is the upstream, framework-agnostic record of a feature:

```
features/
  start-stop-timer/
    feature.md                                  # current intended behaviour, client language
  manual-time-entry/
    feature.md
    iteration-2026-11-03-admin-edits-others.md  # why the behaviour changed
  billable-entries/
    feature.md
    bugfix-2026-11-04-default-overrides-entry.md
```

Rules:
- `feature.md` describes **what**, never how. It is a living document: an
  accepted iteration updates it; the iteration file keeps the why.
- A **bugfix** is a mismatch between the system and `feature.md`. It never
  changes `feature.md`. If `feature.md` is silent, it is an iteration, not a bug.
- Frontmatter `entities:` names ontology classes. `status:` moves
  `proposed → specced → implemented → verified` through `/spec` or `/feature`
  (Architect), QA sign-off, and `/opsx:archive`.
- On conflict with `openspec/specs/`, `feature.md` wins and the Architect opens
  a change.

Templates are installed under `.claude/templates/`.

## Infra Environments Config

The SysOps agent resolves Terraform versions and AWS profiles from a per-project
`environments.json`, located at the path defined by the `infra_config` key in
the manifest (default: `infra/environments.json`).

The `install.sh` script copies this template automatically on first install.
To reset it manually:

```bash
cp /tmp/the-bench/templates/environments.json.template infra/environments.json
```

```json
{
  "terraform_version": "1.7.0",
  "environments": {
    "dev": {
      "aws_profile": "mycompany-dev",
      "region": "eu-west-1",
      "state_bucket": "mycompany-tfstate-dev",
      "state_key": "dev/terraform.tfstate",
      "lock_table": "mycompany-tfstate-locks"
    },
    "staging": { "..." },
    "production": { "..." }
  }
}
```

The SysOps agent will:
- Run `tfenv use <terraform_version>` before any Terraform command.
- Prefix all Terraform and AWS CLI commands with `AWS_PROFILE=<profile>`
  for the target environment.
- Stop and flag in "Open Questions" if this file is absent or incomplete.

## Updating Agents

Projects hold a copy of the agents, so updates are explicit: run the
install script with `--upgrade`, review `git diff .claude/`, commit.

## Agent Roles at a Glance

| Agent | Tier | Mode | Primary scope |
|---|---|---|---|
| `architect` | Strategic | Conversational | Planning, specs, ADRs, OpenSpec proposals |
| `backend` | Technical | Task | API, services, data layer, OpenSpec implementation |
| `frontend` | Technical | Task | UI, components, a11y, OpenSpec implementation |
| `sysops` | Technical | Task | Terraform, CI/CD, infra, cloud resources |
| `cybersec` | Technical | Task | Threat review, compliance, security specs (writes only security artifacts) |
| `qa` | Technical | Task | Test strategy, coverage, spec validation |

## OpenSpec Integration

All agents are OpenSpec-aware. The Architect produces change proposals
(`/opsx:propose`). Technical agents consume the generated `tasks.md` and
`specs/` as their source of truth.

```
Human      →  features/<slug>/feature.md (from meetings, in client language)
Architect  →  validates entities against ontology + data model + API contract
              stops on a gap, otherwise proposal.md + design.md + specs/ + tasks.md
Backend    →  reads tasks.md, implements, reports blockers
QA         →  reads specs/ and feature.md, validates, signs off
Archive    →  /opsx:archive merges specs, feature becomes `verified`
```

---

> Agents are instructions, not magic. Their quality depends on the quality
> of the context they receive. Keep `context/` up to date.
