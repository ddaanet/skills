## Current task

Both preflight briefs in `docs/plans/` are implemented, and the `proof`/`relecture` pair is resynced and parity-checked. Nothing is mid-flight. The next piece of work is evidence rather than code: a skill-creator eval loop over the pair, to show that batch-apply still lands every edit now that the bottom-to-top ordering hint is gone.

## Open decisions

- Whether the two spent brief files (`docs/plans/2026-07-27-preflight-generic-scope-brief.md`, `docs/plans/2026-07-29-preflight-agent-run-release-brief.md`) belong in the repo as an archive of landed decisions, or should be deleted as working docs whose content now lives in the skills and in `design/preflight/DESIGN.md`.
- Which baseline arm the relecture evals compare against: skill-creator's "improving an existing skill" path wants a snapshot of the pre-`2d73fa2` version, while a plain no-skill run measures something else. The change under test is a deletion, so the pre-`2d73fa2` snapshot is the informative arm.