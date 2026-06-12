# ddaa-handoff / ddaa-passation Extraction Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extract the resume-summary handoff out of the `ddaa`/`ddaa-fr` bundles into two new sibling plugins (`ddaa-handoff`, `ddaa-passation`) in the same monorepo, so handoff becomes a per-project plugin choice that no longer collides with the standalone `handoff` plugin.

**Architecture:** The `skills` monorepo holds N subdir plugins under `plugins/<name>/`, versioned in **lockstep** (one version, one repo tag, `just release`). We add two plugins by `git mv`-ing the `handoff` and `passation` skill directories out of `ddaa`/`ddaa-fr`, then extend the three pieces of tooling that enumerate plugins by hand: `build.sh` (path-keyed `.skill` suffix logic), the `justfile` `plugins` lockstep list + `precommit`, and `CLAUDE.md`. The marketplace repo (`../claude-plugins`) gets two new `git-subdir` entries plus edited `ddaa`/`ddaa-fr` entries. The final release is a single `just release minor` that bumps all four plugins 0.2.0 → 0.3.0 and the marketplace in one step.

**Tech Stack:** Claude Code plugin manifests (JSON), Markdown skills, Bash (`build.sh`), `just`, `jq`, `git`. No application code, so "tests" are the repo's own validation gates (`just precommit`, `jq` parse, `build.sh` output, plugin auto-discovery).

**Cross-repo note:** All commands use absolute paths / `git -C` so they run from any working directory. Skill content moves **verbatim**; only the `ddaa-handoff`/`ddaa-passation` skill *descriptions* change (trigger parity). The standalone `handoff` plugin's parity edit is a **separate plan** (`/Users/david/code/handoff/plans/2026-06-12-handoff-trigger-parity.md`).

**Canonical EN trigger set** (shared with the standalone handoff via the parity plan; union of both skills' current triggers, kept whole):
`/handoff`, `handoff`, `save handoff`, `save context`, `prepare handoff`, `write handoff`, `before /clear`, `before I clear`, `clear handoff`, `discard handoff`, `clean handoff`, `finalize`, `wrap up`, `I'm done`, `summarize so I can continue tomorrow`, `conversation too long`, `let's pick this up in a new chat`, `end`, `goodbye`.

**Canonical FR trigger set** (French rendering of the above, for `passation` — David to confirm idiom):
`/passation`, `passation`, `sauvegarde la passation`, `sauvegarde le contexte`, `prépare une passation`, `écris la passation`, `avant /clear`, `avant de clear`, `efface la passation`, `abandonne la passation`, `passation propre`, `finalise`, `on conclut`, `j'ai terminé`, `résume pour continuer demain`, `conversation trop longue`, `on reprend dans un nouveau chat`, `fin`, `au revoir`.

---

## File Structure

**Created:**
- `plugins/ddaa-handoff/.claude-plugin/plugin.json` — manifest, version 0.2.0 (joins lockstep).
- `plugins/ddaa-handoff/skills/handoff/` — moved from `plugins/ddaa/skills/handoff/` (SKILL.md + references/).
- `plugins/ddaa-passation/.claude-plugin/plugin.json` — manifest, version 0.2.0.
- `plugins/ddaa-passation/skills/passation/` — moved from `plugins/ddaa-fr/skills/passation/`.

**Modified:**
- `build.sh` — add the two new plugin dirs to the path → suffix `case` (else they hit "unknown location → skip" and silently don't build).
- `justfile` — extend `plugins` lockstep var to four; add the two new manifests to `precommit`.
- `CLAUDE.md` — lockstep is now four plugins; arborescence shows the new plugins; note handoff/passation moved out.
- `plugins/ddaa/skills/handoff/` → **removed** (by the `git mv` in Task 1).
- `plugins/ddaa-fr/skills/passation/` → **removed** (by the `git mv` in Task 2).
- `../claude-plugins/.claude-plugin/marketplace.json` — add two entries; trim `ddaa`/`ddaa-fr` description + keywords.

**Unchanged:** the `handoff` standalone plugin (separate repo + plan), `onekeys` (its `h` default → `/handoff:handoff`, still valid).

---

## Task 1: Create `ddaa-handoff` plugin (move the handoff skill)

**Files:**
- Create: `plugins/ddaa-handoff/.claude-plugin/plugin.json`
- Move: `plugins/ddaa/skills/handoff/` → `plugins/ddaa-handoff/skills/handoff/`

- [ ] **Step 1: Create the manifest** (new file — `version-guard` does not fire on creation)

Write `/Users/david/code/skills/plugins/ddaa-handoff/.claude-plugin/plugin.json`:

```json
{
  "name": "ddaa-handoff",
  "version": "0.2.0",
  "description": "Resume-summary handoff (EN) — end-of-session summary to continue work in a new chat, delivered to Notion when available. Enable this OR the lightweight handoff plugin, not both.",
  "author": {
    "name": "David Allouche",
    "email": "david@ddaa.net"
  },
  "license": "MIT"
}
```

- [ ] **Step 2: Move the skill directory with history**

Run:
```bash
mkdir -p /Users/david/code/skills/plugins/ddaa-handoff/skills
git -C /Users/david/code/skills mv plugins/ddaa/skills/handoff plugins/ddaa-handoff/skills/handoff
```

- [ ] **Step 3: Verify the move**

Run:
```bash
test -f /Users/david/code/skills/plugins/ddaa-handoff/skills/handoff/SKILL.md \
  && test -f /Users/david/code/skills/plugins/ddaa-handoff/skills/handoff/references/template.md \
  && test ! -e /Users/david/code/skills/plugins/ddaa/skills/handoff \
  && echo OK
```
Expected: `OK`

- [ ] **Step 4: Validate the manifest parses**

Run: `jq . /Users/david/code/skills/plugins/ddaa-handoff/.claude-plugin/plugin.json > /dev/null && echo OK`
Expected: `OK`

- [ ] **Step 5: Commit**

```bash
git -C /Users/david/code/skills add -A plugins/ddaa-handoff plugins/ddaa/skills
git -C /Users/david/code/skills commit -m "feat: extract handoff into ddaa-handoff plugin"
```

---

## Task 2: Create `ddaa-passation` plugin (move the passation skill)

**Files:**
- Create: `plugins/ddaa-passation/.claude-plugin/plugin.json`
- Move: `plugins/ddaa-fr/skills/passation/` → `plugins/ddaa-passation/skills/passation/`

- [ ] **Step 1: Create the manifest**

Write `/Users/david/code/skills/plugins/ddaa-passation/.claude-plugin/plugin.json`:

```json
{
  "name": "ddaa-passation",
  "version": "0.2.0",
  "description": "Passation résumé de session (FR) — résumé de fin de session pour continuer dans un nouveau chat, livré sur Notion quand c'est disponible. Activer celui-ci OU le plugin handoff léger, pas les deux.",
  "author": {
    "name": "David Allouche",
    "email": "david@ddaa.net"
  },
  "license": "MIT"
}
```

- [ ] **Step 2: Move the skill directory with history**

Run:
```bash
mkdir -p /Users/david/code/skills/plugins/ddaa-passation/skills
git -C /Users/david/code/skills mv plugins/ddaa-fr/skills/passation plugins/ddaa-passation/skills/passation
```

- [ ] **Step 3: Verify the move**

Run:
```bash
test -f /Users/david/code/skills/plugins/ddaa-passation/skills/passation/SKILL.md \
  && test -f /Users/david/code/skills/plugins/ddaa-passation/skills/passation/references/template.md \
  && test ! -e /Users/david/code/skills/plugins/ddaa-fr/skills/passation \
  && echo OK
```
Expected: `OK`

- [ ] **Step 4: Validate the manifest parses**

Run: `jq . /Users/david/code/skills/plugins/ddaa-passation/.claude-plugin/plugin.json > /dev/null && echo OK`
Expected: `OK`

- [ ] **Step 5: Commit**

```bash
git -C /Users/david/code/skills add -A plugins/ddaa-passation plugins/ddaa-fr/skills
git -C /Users/david/code/skills commit -m "feat: extract passation into ddaa-passation plugin"
```

---

## Task 3: Teach `build.sh` the new plugin locations

The path → suffix `case` in `build.sh` only knows `./plugins/ddaa/skills/*` and `./plugins/ddaa-fr/skills/*`; any other location hits `*) echo "skipping … unknown location"; continue`. After Tasks 1–2 the handoff/passation `SKILL.md` live under the new dirs, so **without this change they silently stop building into `dist/`**. (`handoff`/`passation` keep suffix `""` via the existing `short_name` case, so output names stay `handoff.skill` / `passation.skill`.)

**Files:**
- Modify: `build.sh` (the `case "$src_dir" in` block)

- [ ] **Step 1: Add the two locations to the case**

In `/Users/david/code/skills/build.sh`, change:

```bash
  case "$src_dir" in
    ./plugins/ddaa/skills/*)     suffix="-en" ;;
    ./plugins/ddaa-fr/skills/*)  suffix="-fr" ;;
    *) echo "⚠️  skipping $src_dir — unknown location"; continue ;;
  esac
```
to:
```bash
  case "$src_dir" in
    ./plugins/ddaa/skills/*)            suffix="-en" ;;
    ./plugins/ddaa-fr/skills/*)         suffix="-fr" ;;
    ./plugins/ddaa-handoff/skills/*)    suffix="-en" ;;
    ./plugins/ddaa-passation/skills/*)  suffix="-fr" ;;
    *) echo "⚠️  skipping $src_dir — unknown location"; continue ;;
  esac
```
(The `-en`/`-fr` here is overridden to `""` for `handoff`/`passation` by the existing `case "$short_name" in handoff|passation) suffix="" ;;` block immediately below — these values just keep the dirs "known". Using `-en`/`-fr` is future-proof if other skills are ever added to these plugins.)

- [ ] **Step 2: Run the build and confirm both skills still build, with no skip warning**

Run:
```bash
( cd /Users/david/code/skills && bash build.sh ) 2>&1 | tee /tmp/build.out
ls /Users/david/code/skills/dist/handoff.skill /Users/david/code/skills/dist/passation.skill
! grep -q "skipping .*ddaa-handoff\|skipping .*ddaa-passation" /tmp/build.out && echo "NO-SKIP-OK"
```
Expected: both `.skill` files listed; `NO-SKIP-OK` printed; build summary shows the same skill count as before the move (11 — relocation, not addition).

- [ ] **Step 3: Commit**

```bash
git -C /Users/david/code/skills add build.sh
git -C /Users/david/code/skills commit -m "🔧 build.sh: recognize ddaa-handoff/ddaa-passation skill dirs"
```

---

## Task 4: Extend the lockstep `plugins` list and `precommit`

**Files:**
- Modify: `justfile` (`plugins :=` line and the `precommit` recipe)

- [ ] **Step 1: Add the new plugins to the lockstep var**

In `/Users/david/code/skills/justfile`, change:
```just
plugins := "ddaa ddaa-fr"
```
to:
```just
plugins := "ddaa ddaa-fr ddaa-handoff ddaa-passation"
```

- [ ] **Step 2: Add the new manifests to `precommit`**

In the same file, change the `precommit` recipe:
```just
precommit:
    bash build.sh > /dev/null
    jq . plugins/ddaa/.claude-plugin/plugin.json > /dev/null
    jq . plugins/ddaa-fr/.claude-plugin/plugin.json > /dev/null
```
to:
```just
precommit:
    bash build.sh > /dev/null
    jq . plugins/ddaa/.claude-plugin/plugin.json > /dev/null
    jq . plugins/ddaa-fr/.claude-plugin/plugin.json > /dev/null
    jq . plugins/ddaa-handoff/.claude-plugin/plugin.json > /dev/null
    jq . plugins/ddaa-passation/.claude-plugin/plugin.json > /dev/null
```

- [ ] **Step 3: Run precommit**

Run: `( cd /Users/david/code/skills && just precommit )`
Expected: exits 0 (build runs, all four manifests parse). No output to stderr.

- [ ] **Step 4: Verify the lockstep invariant holds (all four at 0.2.0)**

Run:
```bash
for p in ddaa ddaa-fr ddaa-handoff ddaa-passation; do
  jq -r .version /Users/david/code/skills/plugins/$p/.claude-plugin/plugin.json
done | sort -u
```
Expected: a single line `0.2.0` (proves lockstep precondition for `just release`).

- [ ] **Step 5: Commit**

```bash
git -C /Users/david/code/skills add justfile
git -C /Users/david/code/skills commit -m "🔧 release tooling: version four plugins in lockstep"
```

---

## Task 5: Rewrite the `ddaa-handoff` handoff description (trigger parity)

Apply the canonical EN trigger set; keep the existing behavioral clause. Skill body is unchanged.

**Files:**
- Modify: `plugins/ddaa-handoff/skills/handoff/SKILL.md` (frontmatter `description` only)

- [ ] **Step 1: Replace the frontmatter description block**

In `/Users/david/code/skills/plugins/ddaa-handoff/skills/handoff/SKILL.md`, replace the whole `description: >- … ---` block with:

```yaml
description: >-
  Prepare a handoff summary to continue work in a new chat. Capture
  completed work, pending tasks, blockers, and learnings; deliver to Notion
  (link only) when it's available. Triggers on "/handoff", "handoff", "save
  handoff", "save context", "prepare handoff", "write handoff", "before
  /clear", "before I clear", "clear handoff", "discard handoff", "clean
  handoff", "finalize", "wrap up", "I'm done", "summarize so I can continue
  tomorrow", "conversation too long", "let's pick this up in a new chat",
  "end", "goodbye". Use when the user wants to transfer context to a future
  conversation or close the session cleanly.
```

- [ ] **Step 2: Confirm the frontmatter still parses and carries the new triggers**

Run:
```bash
python3 -c "import sys,yaml; d=yaml.safe_load(open('/Users/david/code/skills/plugins/ddaa-handoff/skills/handoff/SKILL.md').read().split('---')[1]); assert d['name']=='handoff'; assert 'save context' in d['description'] and 'goodbye' in d['description']; print('OK')"
```
Expected: `OK` (if `pyyaml` is unavailable, instead `grep -q 'save context' … && grep -q 'goodbye' … && echo OK`).

- [ ] **Step 3: Build to confirm no frontmatter breakage**

Run: `( cd /Users/david/code/skills && bash build.sh > /dev/null ) && ls /Users/david/code/skills/dist/handoff.skill && echo OK`
Expected: `handoff.skill` present, `OK`.

- [ ] **Step 4: Commit**

```bash
git -C /Users/david/code/skills add plugins/ddaa-handoff/skills/handoff/SKILL.md
git -C /Users/david/code/skills commit -m "✨ ddaa-handoff: trigger parity with standalone handoff"
```

---

## Task 6: Rewrite the `ddaa-passation` passation description (trigger parity, FR)

**Files:**
- Modify: `plugins/ddaa-passation/skills/passation/SKILL.md` (frontmatter `description` only)

- [ ] **Step 1: Replace the frontmatter description block**

In `/Users/david/code/skills/plugins/ddaa-passation/skills/passation/SKILL.md`, replace the whole `description: >- … ---` block with:

```yaml
description: >-
  Préparer un résumé de passation pour continuer le travail dans un nouveau
  chat. Capturer le travail accompli, les tâches en attente, les blocages,
  et les enseignements ; livrer sur Notion (lien seul) quand c'est
  disponible. Se déclenche sur "/passation", "passation", "sauvegarde la
  passation", "sauvegarde le contexte", "prépare une passation", "écris la
  passation", "avant /clear", "avant de clear", "efface la passation",
  "abandonne la passation", "passation propre", "finalise", "on conclut",
  "j'ai terminé", "résume pour continuer demain", "conversation trop
  longue", "on reprend dans un nouveau chat", "fin", "au revoir". Utiliser
  quand l'utilisateur veut transférer le contexte vers une conversation
  future ou couper la session proprement.
```

> NOTE for David: confirm the French idiom of the new trigger phrases before release; the behavioral clause is unchanged from the original.

- [ ] **Step 2: Confirm parse + new triggers present**

Run:
```bash
grep -q 'sauvegarde le contexte' /Users/david/code/skills/plugins/ddaa-passation/skills/passation/SKILL.md \
  && grep -q 'au revoir' /Users/david/code/skills/plugins/ddaa-passation/skills/passation/SKILL.md \
  && echo OK
```
Expected: `OK`

- [ ] **Step 3: Build to confirm no frontmatter breakage**

Run: `( cd /Users/david/code/skills && bash build.sh > /dev/null ) && ls /Users/david/code/skills/dist/passation.skill && echo OK`
Expected: `passation.skill` present, `OK`.

- [ ] **Step 4: Commit**

```bash
git -C /Users/david/code/skills add plugins/ddaa-passation/skills/passation/SKILL.md
git -C /Users/david/code/skills commit -m "✨ ddaa-passation: parité des déclencheurs avec passation EN"
```

---

## Task 7: Update `CLAUDE.md` (lockstep is four plugins; arborescence)

**Files:**
- Modify: `CLAUDE.md` (the **Plugins** / **Release** convention lines and the **Arborescence** block)

- [ ] **Step 1: Update the Plugins convention line**

In `/Users/david/code/skills/CLAUDE.md`, replace:
```
- **Plugins :** `ddaa` (EN, baseline) et `ddaa-fr` (FR) — sous-dossiers
  de `plugins/`, auto-découverte `skills/*/SKILL.md` dans chacun. Le
  repo racine n'est plus lui-même un plugin.
```
with:
```
- **Plugins :** `ddaa` (EN, baseline), `ddaa-fr` (FR), `ddaa-handoff`
  (EN, passation/handoff résumé extrait), `ddaa-passation` (FR) —
  sous-dossiers de `plugins/`, auto-découverte `skills/*/SKILL.md` dans
  chacun. Le repo racine n'est plus lui-même un plugin. Le handoff résumé
  vit dans son propre plugin pour être un choix par projet, mutuellement
  exclusif avec le plugin `handoff` léger (n'en activer qu'un).
```

- [ ] **Step 2: Update the Release convention line (lockstep count)**

Replace `**Release :** … `ddaa` et `ddaa-fr` sont versionnés en **lockstep**…` so it reads "les quatre plugins (`ddaa`, `ddaa-fr`, `ddaa-handoff`, `ddaa-passation`) sont versionnés en **lockstep** (même version, tag unique `vX.Y.Z`)." Leave the rest of the sentence intact.

- [ ] **Step 3: Update the Arborescence block**

In the ```` ``` ```` arborescence, remove `handoff/` from under `ddaa/skills/` and `passation/` from under `ddaa-fr/skills/`, and add two new plugin blocks:
```
  ddaa-handoff/                  # plugin Claude Code — EN (résumé)
    .claude-plugin/plugin.json
    skills/
      handoff/
  ddaa-passation/                # plugin Claude Code — FR (résumé)
    .claude-plugin/plugin.json
    skills/
      passation/
```

- [ ] **Step 4: Sanity check the doc**

Run: `grep -c 'ddaa-handoff\|ddaa-passation' /Users/david/code/skills/CLAUDE.md`
Expected: `≥ 3` (Plugins line, Release line, arborescence).

- [ ] **Step 5: Commit**

```bash
git -C /Users/david/code/skills add CLAUDE.md
git -C /Users/david/code/skills commit -m "📝 CLAUDE.md: lockstep over four plugins, handoff extracted"
```

---

## Task 8: Add marketplace entries; trim `ddaa`/`ddaa-fr` entries

The marketplace lives in the sibling repo `../claude-plugins`. The `just release` recipe requires a marketplace entry for **every** name in the lockstep `plugins` var (pre-flight) and bumps them all, so these must exist (at 0.2.0) before release. It also requires `../claude-plugins` to have **no uncommitted changes** at release time — so commit this now.

**Files:**
- Modify: `/Users/david/code/claude-plugins/.claude-plugin/marketplace.json`

- [ ] **Step 1: Add two entries to the `.plugins` array**

Insert after the `ddaa-fr` entry:
```json
    {
      "name": "ddaa-handoff",
      "source": {
        "source": "git-subdir",
        "url": "ddaanet/skills",
        "path": "plugins/ddaa-handoff"
      },
      "description": "Resume-summary handoff (EN) — end-of-session summary to continue in a new chat, delivered to Notion when available. Enable this OR the lightweight `handoff` plugin, not both.",
      "version": "0.2.0",
      "author": { "name": "David Allouche" },
      "repository": "https://github.com/ddaanet/skills",
      "license": "MIT",
      "keywords": ["handoff", "session", "summary", "notion", "english"]
    },
    {
      "name": "ddaa-passation",
      "source": {
        "source": "git-subdir",
        "url": "ddaanet/skills",
        "path": "plugins/ddaa-passation"
      },
      "description": "Passation résumé de session (FR) — résumé de fin de session pour continuer dans un nouveau chat, livré sur Notion quand c'est disponible. Activer celui-ci OU le plugin `handoff` léger, pas les deux.",
      "version": "0.2.0",
      "author": { "name": "David Allouche" },
      "repository": "https://github.com/ddaanet/skills",
      "license": "MIT",
      "keywords": ["passation", "handoff", "session", "notion", "francais"]
    },
```

- [ ] **Step 2: Trim the `ddaa` entry**

In the `ddaa` entry, set `description` to `"Skills (EN) — brief, preflight, proof, bilingual skill creator, bookkeeping."` and remove `"handoff"` from its `keywords` array.

- [ ] **Step 3: Trim the `ddaa-fr` entry**

In the `ddaa-fr` entry, set `description` to `"Skills (FR) — brief, preflight, relecture, saisie comptable."` and remove `"passation"` from its `keywords` array.

- [ ] **Step 4: Validate the manifest**

Run:
```bash
jq -e '.plugins | map(.name) | index("ddaa-handoff") and index("ddaa-passation")' /Users/david/code/claude-plugins/.claude-plugin/marketplace.json >/dev/null \
  && jq -e '.plugins[] | select(.name=="ddaa") | (.keywords | index("handoff") | not)' /Users/david/code/claude-plugins/.claude-plugin/marketplace.json >/dev/null \
  && echo OK
```
Expected: `OK`

- [ ] **Step 5: Commit in the marketplace repo**

```bash
git -C /Users/david/code/claude-plugins add .claude-plugin/marketplace.json
git -C /Users/david/code/claude-plugins commit -m "✨ marketplace: add ddaa-handoff/ddaa-passation, trim ddaa entries"
```

---

## Task 9: Release (lockstep minor) — **run by David**

`just release` performs irreversible operations (tag, push to `github`, GitHub release, push to the marketplace repo). Per project history the marketplace push is sometimes blocked for the agent, so **David runs this step**.

- [ ] **Step 1: Final precommit + clean tree check**

Run:
```bash
( cd /Users/david/code/skills && just precommit ) \
  && git -C /Users/david/code/skills status --porcelain \
  && git -C /Users/david/code/claude-plugins status --porcelain
```
Expected: precommit exits 0; both `status --porcelain` print nothing (clean trees — release refuses otherwise).

- [ ] **Step 2: Release** (David, in a terminal)

```
cd /Users/david/code/skills && just release minor
```
Expected: prompts `Release ddaa ddaa-fr ddaa-handoff ddaa-passation 0.2.0 -> 0.3.0? [y/N]`; on `y`, bumps all four manifests, commits `release: 0.3.0`, tags `v0.3.0`, pushes main + tag, creates the GitHub release, bumps all four marketplace entries to 0.3.0 and pushes `claude-plugins`.

- [ ] **Step 3: Verify**

Run:
```bash
git -C /Users/david/code/skills describe --tags --abbrev=0
jq -r '.plugins[] | select(.name|test("^ddaa")) | "\(.name) \(.version)"' /Users/david/code/claude-plugins/.claude-plugin/marketplace.json
```
Expected: `v0.3.0`; all four `ddaa*` entries at `0.3.0`.

---

## Post-implementation

- Run the **handoff parity plan** (`/Users/david/code/handoff/plans/2026-06-12-handoff-trigger-parity.md`) so the standalone `handoff` plugin adopts the same canonical EN set.
- In any project that should use the resume-summary handoff, enable `ddaa-handoff` (or `ddaa-passation`) in `.claude/settings.json` and ensure `handoff` is **not** also enabled there.
