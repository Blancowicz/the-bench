# /spec — Planning and specification workflow (no implementation)

Produce a complete spec for the following feature or change:

**Request**: $ARGUMENTS

---

This command covers planning only. No code will be written.
Use `/feature` when you are ready to implement.

## Step 1 — Compact context

If the current context is large, compact it before starting.

## Step 2 — Architect: scope and spec

Use the **architect** agent to:
1. Read `SESSION.md` and the full project context.
2. Scope the request against `context/products` and `context/contracts`.
3. Check all `accepted` ADRs for constraints.
4. Use `/opsx:explore` to investigate the codebase if needed.
5. Present a summary of:
   - What is in scope and what is not
   - Key constraints from ADRs or contracts
   - Proposed technical approach
   - Open questions requiring human input
6. Wait for **human confirmation and resolution of open questions**.
7. Once confirmed, run `/opsx:propose` to produce:
   - `proposal.md`
   - `design.md`
   - `specs/<domain>/spec.md`
   - `tasks.md` with every task tagged `[AGENT]`

## Step 3 — Cybersec pre-review

If the spec introduces any of the following, use the **cybersec** agent
to review the spec before finalising:
- Authentication or authorisation logic
- PII handling
- External integrations
- New public endpoints

Cybersec may produce additional delta specs. These must be reviewed
by the Architect and confirmed by a human before tasks.md is finalised.

## Step 4 — Session log

Append a dated entry to `SESSION.md`:
- Feature scoped
- Key decisions made
- Open questions pending resolution
- Spec location in OpenSpec

## Step 5 — Summary

Report back with:
- OpenSpec change name and location
- Domains for which specs were written
- ADRs produced (with status)
- Agent assignments summary from `tasks.md`
- Any open questions still unresolved
- Suggested next step: `/feature <same request>` when ready to implement
