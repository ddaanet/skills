## Brief: https submodule urls for keyless /plugin install (skills)

2026-10-13

### Goal

Installing the `skills` plugin through `/plugin` must never need a GitHub SSH key. Claude Code's `/plugin install` clones with `--recurse-submodules`. The gitlore `memory` submodule url is in SSH form, so a user with no registered key gets `Permission denied (publickey)` and the whole install aborts.

### Decisions

- Change only `.gitmodules` url values to `https://github.com/...`. Local `.git/config` urls stay SSH, so my human partner's pushes are unaffected.
- Worked example: the `sandbox-lies` repo, `dev` branch, commit "https submodule urls, so a marketplace install needs no access to the memory repos". A keyless real install of it succeeded once both urls were https (Claude Code 2.1.296).

### Edits for this repo

- `.gitmodules` (repo root): `url = git@github.com:ddaanet/skills-memory.git` becomes `url = https://github.com/ddaanet/skills-memory.git`.
- `memory/.gitmodules` does not exist here (no nested tier mount), so nothing else to change.

### Target visibility (checked 2026-10-13, anonymous GitHub API)

- `ddaanet/skills-memory`: 404, private or missing. An anonymous install fails until my human partner makes it public. The agent must NOT change visibility itself; ask my human partner to do it.

### Constraints

- Only `.gitmodules` changes. Do not touch `.git/config`.
- Use the Read tool for `.gitmodules`, not `cat` in Bash: the command sandbox masks it.
- The memory repo must be public for an anonymous install to work.

### Verification

After the change is pushed and the memory repo is public:

`HOME="$TMPDIR/anon" GIT_CONFIG_NOSYSTEM=1 GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND=false git -c credential.helper= clone --recurse-submodules https://github.com/ddaanet/skills.git "$TMPDIR/anon-clone"`

Expected exit 0 with `memory/` populated. A credential-less clone fails on any SSH submodule url, and fails on any private repo in the chain.
