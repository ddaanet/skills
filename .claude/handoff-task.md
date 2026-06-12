## Current task

build.sh reviewed via shell-gotchas and rewritten to drop `declare -A` for a `group_for()` case (runs on macOS stock bash 3.2); shellcheck clean, build verified at 11 skills — change is about to be committed.

## Open decisions

- Whether to `git push github main` now. The trailing docs commit `444711e` and the imminent build.sh commit both sit on `main` ahead of the `github` remote and the `v0.3.0` tag; still unpushed from the prior session.
