# /security-audit — Isolated security audit

Run a focused security audit on the following scope:

**Scope**: $ARGUMENTS

---

If no scope is provided, audit the entire codebase.
This command runs Cybersec in isolation, independent of any active OpenSpec change.

## Step 1 — Compact context

If the current context is large, compact it before starting.

## Step 2 — Cybersec: context load

Use the **cybersec** agent to:
1. Read `SESSION.md` for any prior security notes.
2. Read the full `context/contracts` path (resolved via manifest) for
   compliance obligations.
3. Read all `accepted` ADRs for existing security decisions.

## Step 3 — Cybersec: threat model

For the specified scope, produce a full threat model:
1. Identify entry points and assets at risk.
2. Apply STRIDE across the scope.
3. Rate each finding: Critical / High / Medium / Low.
4. Propose mitigations in order of priority.

## Step 4 — Cybersec: compliance check

Cross-reference findings against compliance obligations from contracts:
- Flag any gap between current implementation and regulatory requirements.
- Produce a compliance gap report.

## Step 5 — Cybersec: spec production

For each Critical or High finding, produce a delta spec in OpenSpec format:
- Written as `## ADDED Requirements` in the relevant domain.
- Every requirement has at least one Given/When/Then scenario.
- Flag specs for Architect review before tagging tasks.

## Step 6 — Architect escalation (if needed)

If any finding requires architectural change (not just implementation fix),
flag it explicitly for Architect review.

Do not produce tasks for architectural changes without Architect sign-off.

## Step 7 — Session log

Append a dated entry to `SESSION.md`:
- Audit scope
- Summary of findings by severity
- Specs produced
- Escalations to Architect

## Step 8 — Summary

Report back with:
- Audit scope
- Findings by severity (Critical / High / Medium / Low count)
- Specs produced and their locations
- Compliance gaps identified
- Escalations requiring Architect and human review
- Suggested next steps
