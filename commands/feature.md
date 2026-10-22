# /feature — Full feature implementation workflow

Execute the full feature development workflow for the following request:

**Feature**: $ARGUMENTS

---

Follow these steps in order. Do not skip steps. Wait for human confirmation
where indicated before proceeding.

## Step 1 — Compact context

If the current context is large, compact it before starting.
This keeps the session clean for the work ahead.

## Step 2 — Create a branch

Create a new git branch:
```
feature/<kebab-case-slug-derived-from-the-feature-name>
```

## Step 3 — Architect: scope and spec

If a change already exists for this feature (frontmatter `openspec:` set and
`status: specced`, typically after `/spec`), skip to Step 4.

Otherwise use the **architect** agent to:
1. Read `SESSION.md` and the full project context.
2. Resolve the request to a folder under `features`; read `feature.md` and the
   most recent open iteration or bugfix. Draft `feature.md` if missing and
   ask for confirmation.
3. Validate `entities:` against the ontology and data model, and endpoints
   against the API contract. A parked or missing term is a blocker: stop and
   report it under "Context Gaps".
4. Scope the feature against `products` and `contracts`.
5. Check all `accepted` ADRs for constraints.
6. Explore with `/opsx:explore` if the request is ambiguous.
7. Present the proposed approach and wait for **human confirmation**.
8. Once confirmed, run `/opsx:propose` to produce:
   - `proposal.md`
   - `design.md`
   - `specs/<domain>/spec.md`
   - `tasks.md` with every task tagged `[AGENT]`
9. Update the feature frontmatter: `openspec: changes/<change>`, `status: specced`.

**Do not proceed to Step 4 until the human confirms the spec.**

## Step 4 — Implementation

Read `tasks.md`. For each task:
- `[BACKEND]` → use the **backend** agent
- `[FRONTEND]` → use the **frontend** agent
- `[SYSOPS]` → use the **sysops** agent
- `[CYBERSEC]` → use the **cybersec** agent

Agents may run in parallel if their tasks are independent.
Agents must mark tasks complete in `tasks.md` as they finish (`- [x]`).

## Step 5 — QA sign-off

Use the **qa** agent to:
1. Validate all spec scenarios have passing tests.
2. Check for regressions against existing specs.
3. Produce a sign-off or list of blockers.
4. On sign-off, set `status: implemented` on the feature (and on the
   iteration file, if one triggered this change).

**Do not proceed to Step 6 if QA withholds sign-off.**

## Step 6 — Session log

Append a dated entry to `SESSION.md` summarising:
- What was implemented
- Any assumptions or open questions
- Anything not captured in specs or ADRs

## Step 7 — Summary

Report back with:
- Branch name
- OpenSpec change name
- Tasks completed per agent
- QA sign-off status
- Feature status
- Next steps: PR, then `/opsx:archive` (which sets the feature to `verified`)
