# /review — Code and security review of current changes

Review the current changes in this branch.

**Scope** (optional): $ARGUMENTS

---

If no scope is provided, review all changes on the current branch
relative to the main branch.

## Step 1 — QA review

Use the **qa** agent to:
1. Run `git diff main` (or equivalent) to identify changed files.
2. Cross-reference changes against the active OpenSpec specs.
3. Verify all relevant Given/When/Then scenarios have passing tests.
4. Check for regressions against existing specs.
5. Produce a structured report:
   - Spec coverage per domain
   - Bugs found (with severity and responsible agent)
   - Missing tests
   - QA sign-off or list of blockers

## Step 2 — Cybersec review

Use the **cybersec** agent to:
1. Review changed files for security surfaces:
   - Auth and authorisation logic
   - PII handling
   - Input validation
   - Secrets or credentials
   - IAM or infrastructure changes
2. Produce a threat summary and any security requirements not yet covered.
3. Flag any findings that require Architect escalation.

## Step 3 — Session log

Append a dated entry to `SESSION.md`:
- Review scope
- Key findings from QA and Cybersec
- Any blockers or open questions

## Step 4 — Summary

Report back with:
- QA sign-off status
- Cybersec findings summary (Critical / High / Medium / Low)
- Combined list of blockers before this branch can be merged
- Suggested next steps
