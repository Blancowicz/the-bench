# /archive — Close a change after QA sign-off

Archive the following OpenSpec change and move its feature record forward:

**Change**: $ARGUMENTS

---

This command runs after `/feature` or `/bugfix` has ended with a QA sign-off.
It is the only place where `openspec/specs/` changes. Use the **architect** agent.

## Step 1 — Preconditions

1. `openspec/changes/<change>/tasks.md` has no unchecked task.
2. A QA sign-off exists for the change (`qa-signoff.md` or the equivalent) with
   the verdict "ready to archive". If it is missing or withheld, stop and say so.
3. `openspec validate --all --strict` is clean.

If any precondition fails, report it and stop. Do not archive.

## Step 2 — Archive

Run `openspec archive <change> -y` from the repository root. Confirm that every
delta spec of the change was merged into `openspec/specs/` and that validation
is still clean afterwards.

## Step 3 — Feature record

Resolve the feature folder from `proposal.md` (`Feature:` line, plus
`Iteration:` or `Bugfix:` if present) under the `features` context path:

- `feature.md` and, if any, the iteration file: `status: verified`,
  `openspec:` pointing to the archived folder, and a Historial row
  ("verificación", today's date, archived path, one-line summary).
- A bugfix file: `status: fixed` (if not already), `openspec:` pointing to the
  archived folder. `feature.md` does not change on a bugfix.
- A change with `Feature: none`: nothing to move.

## Step 4 — Plan and tickets

If the `plan` context path holds a roadmap or ticket files that reference this
feature, iteration or bugfix, set their status to done/verified. Do not create
new plan entries.

## Step 5 — Session log

Append a dated `[ARCHITECT]` entry to `SESSION.md`: change archived, specs
merged (created/modified/removed), feature status, what remains open.

## Step 6 — Summary

Report back with:
- Archived path and the specs merged
- Feature, iteration or bugfix files updated and their new status
- Plan and ticket updates
- Suggested commit message
