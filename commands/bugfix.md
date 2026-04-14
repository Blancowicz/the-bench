# /bugfix — Bug investigation and fix workflow

Investigate and fix the following bug:

**Bug**: $ARGUMENTS

---

Follow these steps in order.

## Step 1 — Compact context

If the current context is large, compact it before starting.

## Step 2 — Create a branch

Create a new git branch:
```
fix/<kebab-case-slug-derived-from-the-bug-description>
```

## Step 3 — Diagnose

Use the **qa** agent to:
1. Read `SESSION.md` for any related previous notes.
2. Reproduce the bug if possible.
3. Identify the failing spec scenario, if one exists.
4. If no spec covers this behaviour, flag it as a spec gap to the Architect.
5. Produce a bug report with:
   - Spec reference (or gap)
   - Severity
   - Responsible agent
   - Steps to reproduce
   - Expected vs actual behaviour

## Step 4 — Architect review (if spec gap)

If QA flagged a spec gap, use the **architect** agent to:
1. Decide whether the gap is a missing requirement or an implementation defect.
2. If missing requirement: produce a delta spec before proceeding.
3. Wait for **human confirmation** before proceeding.

Skip this step if the bug has a clear spec reference.

## Step 5 — Fix

Delegate the fix to the responsible agent identified in Step 3:
- `[BACKEND]` → **backend** agent
- `[FRONTEND]` → **frontend** agent
- `[SYSOPS]` → **sysops** agent

The agent must:
1. Implement the minimal fix that resolves the root cause.
2. Write or update tests to cover the scenario.
3. Mark the task complete in `tasks.md` if one exists.

## Step 6 — Cybersec check (if security surface)

If the bug involves auth, PII, or access control, use the **cybersec** agent
to review the fix before proceeding.

## Step 7 — QA sign-off

Use the **qa** agent to verify:
1. The failing scenario now passes.
2. No regressions in existing specs.

**Do not proceed if QA withholds sign-off.**

## Step 8 — Session log

Append a dated entry to `SESSION.md`:
- Bug description and root cause
- Fix applied
- Any spec gaps identified and resolved

## Step 9 — Summary

Report back with:
- Branch name
- Root cause
- Fix applied
- Tests added or updated
- QA sign-off status
- Next steps
