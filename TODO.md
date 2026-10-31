## Remaining

- Attach the built `.skill` archives to the GitHub release and add the upload step to the `release` recipe. README sends claude.ai users to Releases, but no release has ever carried assets — v0.5.0 and v0.4.0 both list none, while `build.sh` produces 11.
- Fix the marketplace commit message in the `release` recipe: it says `ddaa/ddaa-fr <version>` while bumping all four plugin entries. Same plugin-split staleness the README had.
- Rename the other handoff provider to `autodrive-handoff` and drop "lightweight"/"léger" in one pass: `docs/plans/2026-09-20-handoff-plugin-is-not-lightweight.md` + `docs/plans/2026-10-31-handoff-renamed-autodrive-handoff.md`. Sites beyond the plans' lists: `CLAUDE.md:16` and `:80`. Leave `docs/specs/` alone (frozen).
- Preflight: exclude the gitlore memory submodule from the clean-tree checks: `docs/plans/2026-08-13-preflight-memory-submodule.md`.
- Preflight: end on a release request in the user's own words: `docs/plans/2026-09-07-preflight-release-approval-provenance.md`. f27be16 already releases only when the request asked for one. Still missing: asking the user to state the bump, and the `!`-prefixed command fallback.
- https submodule url (`docs/plans/2026-10-13-https-submodule-urls.md`): `.gitmodules` is edited and `ddaanet/skills-memory` is public (2026-10-31). Still to do: push, then run the plan's anonymous-clone check.
