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

### Install

Run this from your project root:

```bash
curl -fsSL https://raw.githubusercontent.com/tu-org/the-bench/main/install.sh | bash
```

The script will:
- Install agents → `.claude/agents/`
- Install commands → `.claude/commands/`
- Copy templates if not present → `context/manifest.json`, `infra/environments.json`, `SESSION.md`
- Update `.gitignore` with the right entries

### Upgrade

To pull the latest agents and commands without touching your config files:

```bash
curl -fsSL https://raw.githubusercontent.com/tu-org/the-bench/main/install.sh | bash -s -- --upgrade
```

Your `manifest.json`, `environments.json`, and `SESSION.md` are never overwritten on upgrade.

### Manual install (alternative)

If you prefer not to pipe curl to bash, clone and run directly:

```bash
git clone git@github.com:tu-org/the-bench.git /tmp/the-bench
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
