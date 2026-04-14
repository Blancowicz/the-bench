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

Use the **architect** agent to:
1. Read `SESSION.md` and the full project context.
2. Scope the feature against `context/products` and `context/contracts`.
3. Check all `accepted` ADRs for constraints.
4. Explore with `/opsx:explore` if the request is ambiguous.
5. Present the proposed approach and wait for **human confirmation**.
6. Once confirmed, run `/opsx:propose` to produce:
   - `proposal.md`
   - `design.md`
   - `specs/<domain>/spec.md`
   - `tasks.md` with every task tagged `[AGENT]`

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
- Next steps (e.g. PR, deploy to staging)
