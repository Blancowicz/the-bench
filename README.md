# agents

Centralized prompt library for Claude Code agents. Versioned, composable,
and reusable across projects via symlinks.

## Philosophy

- **Separation of concerns** — each agent has a defined scope and does not
  operate outside it.
- **Hierarchy** — strategic agents (Architect) define. Technical agents
  (Backend, Frontend, SysOps, Cybersec, QA) execute.
- **Composability** — all agents inherit shared base behavior via `_base.md`
  and a common context protocol via `_context_loader.md`.
- **Portability** — projects map their own folder structure to logical roles
  via `context/manifest.json`, decoupling agents from any specific layout.

## Repository Structure

```
the-bench/
  _base.md              # Shared behavior: output format, hierarchy, standards
  _context_loader.md    # Protocol for reading project context
  architect.md
  backend.md
  frontend.md
  sysops.md
  cybersec.md
  qa.md
  templates/
    manifest.json.template
    environments.json.template
    SESSION.md.template
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

### 1. Add the repo as a submodule

```bash
git submodule add git@github.com:your-org/agents.git agents
```

### 2. Symlink into your project

```bash
# From the project root
ln -s ./agents .claude/agents
```

### 3. Create the context manifest

Copy the template and edit paths to match your project's context folder:

```bash
cp .claude/agents/templates/manifest.json.template context/manifest.json
```

### 4. Initialize the session log

```bash
cp .claude/agents/templates/SESSION.md.template SESSION.md
```

Update the initial entry date and start logging at the end of each session.

### 5. Reference agents from CLAUDE.md

In your project root `CLAUDE.md`:

```markdown
@.claude/agents/architect.md
```

In sublayers (e.g. `apps/api/CLAUDE.md`):

```markdown
@../../.claude/agents/backend.md
```

## Context Manifest

Each project must have a `context/manifest.json` that maps logical keys to
actual folder paths. This is the only file that lives in the project, not
in this repo.

```json
{
  "version": "1.0",
  "paths": {
    "contracts":    "00-contracts",
    "meetings":     "01-meetings",
    "decisions":    "02-decisions",
    "products":     "09-products",
    "technology":   "06-technology-ecosystem",
    "architecture": "07-architecture-diagrams",
    "consulting":   "08-consulting",
    "plan":         "04-plan",
    "design":       "12-design",
    "data_model":   "07-architecture-diagrams/data-model.yaml",
    "infra_config": "infra/environments.json"
  },
  "disabled": ["05-tasks", "10-recipes"],
  "notes": {
    "consulting": "Strategic input only. Do not treat as decisions.",
    "plan": "Informational. Use for phase validation only."
  }
}
```

If `manifest.json` is absent, agents fall back to the default paths
documented in `_context_loader.md`.

## Infra Environments Config

The SysOps agent resolves Terraform versions and AWS profiles from a per-project
`environments.json`, located at the path defined by the `infra_config` key in
the manifest (default: `infra/environments.json`).

Copy the template and edit it to match your project's environments and AWS profiles:

```bash
cp .claude/agents/templates/environments.json.template infra/environments.json
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

Since projects consume this repo as a submodule, updates are explicit
and controlled:

```bash
# Inside a project — pull latest agents
git submodule update --remote agents

# Review changes before committing
git diff agents
git add agents && git commit -m "chore: update agents to latest"
```

## Agent Roles at a Glance

| Agent | Tier | Mode | Primary scope |
|---|---|---|---|
| `architect` | Strategic | Conversational | Planning, specs, ADRs, OpenSpec proposals |
| `backend` | Technical | Task | API, services, data layer, OpenSpec implementation |
| `frontend` | Technical | Task | UI, components, a11y, OpenSpec implementation |
| `sysops` | Technical | Task | Terraform, CI/CD, infra, cloud resources |
| `cybersec` | Technical | Task | Threat review, compliance, security specs |
| `qa` | Technical | Task | Test strategy, coverage, spec validation |

## OpenSpec Integration

All agents are OpenSpec-aware. The Architect produces change proposals
(`/opsx:propose`). Technical agents consume the generated `tasks.md` and
`specs/` as their source of truth.

```
Architect  →  proposal.md + design.md + specs/ + tasks.md
Backend    →  reads tasks.md, implements, reports blockers
QA         →  reads specs/, validates implementation against scenarios
```

---

> Agents are instructions, not magic. Their quality depends on the quality
> of the context they receive. Keep `context/` up to date.
