# Plugin split implementation plan

> **For agentic workers:** Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Split the monolithic `ddaa` Claude Code plugin into two language-scoped plugins (`ddaa`, `ddaa-fr`), drop `proof`/`relecture`, and keep `handoff`/`passation` as claude.ai-only artifacts.

**Architecture:** Two plugins live in subdirs (`plugins/ddaa`, `plugins/ddaa-fr`). Short, unsuffixed skill names inside each plugin; `build.sh` rewrites them with `-en`/`-fr` suffixes when producing claude.ai `.skill` archives, so the flat claude.ai namespace stays unambiguous.

**Tech Stack:** Shell (`build.sh`), Markdown, JSON.

**Spec:** `docs/specs/2026-04-24-plugin-split-design.md`.

**Repo has no automated tests.** Verification is `./build.sh` producing the expected set of `.skill` files and each plugin tree being structurally valid.

---

## Task 1: Drop proof / relecture

**Files:**
- Delete: `skills/proof/`, `skills/relecture/`, `design/proof/`

- [ ] **Step 1: Remove the three trees**

```bash
cd /Users/david/code/skills
git rm -r skills/proof skills/relecture design/proof
```

- [ ] **Step 2: Commit**

```bash
git commit -m "$(cat <<'EOF'
🔥 drop proof / relecture skills

Proofreading loop lives in candidature and superpowers; the standalone
pair adds nothing. Design doc goes with it.
EOF
)"
```

---

## Task 2: Create plugin tree

**Files:**
- Create: `plugins/ddaa/`, `plugins/ddaa-fr/`

- [ ] **Step 1: Create the skeleton**

```bash
cd /Users/david/code/skills
mkdir -p plugins/ddaa/skills plugins/ddaa-fr/skills plugins/ddaa/.claude-plugin plugins/ddaa-fr/.claude-plugin
```

(No commit — the dirs are empty. The next task populates them.)

---

## Task 3: Move English-side skills into `plugins/ddaa/`

**Files:**
- Move: `skills/brief-en/` → `plugins/ddaa/skills/brief/`
- Move: `skills/preflight-en/` → `plugins/ddaa/skills/preflight/`
- Move: `skills/bilingual-skill-creator/` → `plugins/ddaa/skills/bilingual-skill-creator/`
- Modify SKILL.md frontmatter: `name: brief-en` → `name: brief`; `name: preflight-en` → `name: preflight`; `bilingual-skill-creator` unchanged.

- [ ] **Step 1: git mv each dir**

```bash
cd /Users/david/code/skills
git mv skills/brief-en plugins/ddaa/skills/brief
git mv skills/preflight-en plugins/ddaa/skills/preflight
git mv skills/bilingual-skill-creator plugins/ddaa/skills/bilingual-skill-creator
```

- [ ] **Step 2: Rewrite frontmatter `name` fields**

Use `Edit` on `plugins/ddaa/skills/brief/SKILL.md`:
```
old_string: name: brief-en
new_string: name: brief
```

Use `Edit` on `plugins/ddaa/skills/preflight/SKILL.md`:
```
old_string: name: preflight-en
new_string: name: preflight
```

(`bilingual-skill-creator` frontmatter is already correct.)

- [ ] **Step 3: Verify no stale suffix references in the frontmatter**

```bash
grep -n "^name:" plugins/ddaa/skills/*/SKILL.md
```
Expected: `brief`, `preflight`, `bilingual-skill-creator` — no `-en` remaining.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "$(cat <<'EOF'
♻️ move EN skills into plugins/ddaa/

Short unsuffixed names inside the plugin — "ddaa:brief" reads better
than "ddaa:brief-en" since the plugin prefix already carries the
language.
EOF
)"
```

---

## Task 4: Move French-side skills into `plugins/ddaa-fr/`

**Files:**
- Move: `skills/brief-fr/` → `plugins/ddaa-fr/skills/brief/`
- Move: `skills/preflight-fr/` → `plugins/ddaa-fr/skills/preflight/`
- Modify SKILL.md frontmatter: strip `-fr` suffix from `name`.

- [ ] **Step 1: git mv each dir**

```bash
cd /Users/david/code/skills
git mv skills/brief-fr plugins/ddaa-fr/skills/brief
git mv skills/preflight-fr plugins/ddaa-fr/skills/preflight
```

- [ ] **Step 2: Rewrite frontmatter `name` fields**

Use `Edit` on `plugins/ddaa-fr/skills/brief/SKILL.md`:
```
old_string: name: brief-fr
new_string: name: brief
```

Use `Edit` on `plugins/ddaa-fr/skills/preflight/SKILL.md`:
```
old_string: name: preflight-fr
new_string: name: preflight
```

- [ ] **Step 3: Verify**

```bash
grep -n "^name:" plugins/ddaa-fr/skills/*/SKILL.md
```
Expected: `brief`, `preflight`.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "$(cat <<'EOF'
♻️ move FR skills into plugins/ddaa-fr/

Symmetric to ddaa: unsuffixed names, invocation "ddaa-fr:brief".
EOF
)"
```

---

## Task 5: Write plugin manifests

**Files:**
- Create: `plugins/ddaa/.claude-plugin/plugin.json`
- Create: `plugins/ddaa-fr/.claude-plugin/plugin.json`
- Delete: `.claude-plugin/plugin.json` (and empty parent dir)

- [ ] **Step 1: Write `plugins/ddaa/.claude-plugin/plugin.json`**

```json
{
  "name": "ddaa",
  "version": "0.1.0",
  "description": "Personal toolbox — skills for briefing, preflight validation, and bilingual skill creation.",
  "author": {
    "name": "David Allouche",
    "email": "david@ddaa.net"
  },
  "license": "MIT"
}
```

- [ ] **Step 2: Write `plugins/ddaa-fr/.claude-plugin/plugin.json`**

```json
{
  "name": "ddaa-fr",
  "version": "0.1.0",
  "description": "Boîte à outils personnelle — skills de briefing et validation pré-release en français.",
  "author": {
    "name": "David Allouche",
    "email": "david@ddaa.net"
  },
  "license": "MIT"
}
```

- [ ] **Step 3: Remove the old root manifest**

```bash
cd /Users/david/code/skills
git rm .claude-plugin/plugin.json
rmdir .claude-plugin 2>/dev/null || true
```

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "$(cat <<'EOF'
✨ add per-plugin manifests, drop root manifest

Repo root is no longer a plugin — each subdir under plugins/ is.
EOF
)"
```

---

## Task 6: Rewrite `build.sh`

**Files:**
- Modify: `build.sh`

The new logic must:
1. Find every `SKILL.md` in the repo (same as today), yielding a list of skill source dirs.
2. Classify each source dir by the "plugin channel":
   - path starts with `plugins/ddaa/skills/` → English plugin → `-en` suffix in claude.ai channel.
   - path starts with `plugins/ddaa-fr/skills/` → French plugin → `-fr` suffix.
   - path starts with `skills/` → repo-root claude.ai-only skill → no suffix.
3. For each skill, build a `.skill` archive in `dist/`:
   - Copy the source dir to a tmp staging dir under the suffixed name.
   - Rewrite the `name:` line of the staged `SKILL.md` to the suffixed name (only for suffixed channels).
   - Drop a generated `README.md` into the staging dir pointing to `design/<group>/DESIGN.md` on GitHub.
   - Zip the staging dir into `dist/<suffixed-name>.skill` with the staging dir as the archive root.
   - Remove the staging dir.
4. The `SKILL_GROUP` map is keyed by the unsuffixed short name.

- [ ] **Step 1: Replace `build.sh`**

Write exactly:

```bash
#!/usr/bin/env bash
# Build all .skill files into dist/
# A .skill is a zip containing the skill directory (SKILL.md + references/).
# DESIGN.md lives in design/<group>/ and is NOT included in the package.
# Skills under plugins/ddaa/ are published as <name>-en.skill for claude.ai
# (frontmatter + top-level dir are rewritten). Skills under plugins/ddaa-fr/
# get -fr. Skills under skills/ (handoff, passation) are shipped as-is.

set -euo pipefail

REPO_URL="https://github.com/ddaanet/skills"
DIST="dist"
rm -rf "$DIST"
mkdir -p "$DIST"

# Short skill name → design-group.
declare -A SKILL_GROUP=(
  [brief]=brief
  [preflight]=preflight
  [bilingual-skill-creator]=bilingual-skill-creator
  [handoff]=handoff
  [passation]=handoff
)

stage_root="$(mktemp -d)"
trap 'rm -rf "$stage_root"' EXIT

count=0

while IFS= read -r skill_md; do
  src_dir="$(dirname "$skill_md")"
  short_name="$(basename "$src_dir")"

  # Determine suffix from source path.
  case "$src_dir" in
    ./plugins/ddaa/skills/*)     suffix="-en" ;;
    ./plugins/ddaa-fr/skills/*)  suffix="-fr" ;;
    ./skills/*)                  suffix=""    ;;
    *) echo "⚠️  skipping $src_dir — unknown location"; continue ;;
  esac

  archive_name="${short_name}${suffix}"
  stage_dir="$stage_root/$archive_name"
  cp -r "$src_dir" "$stage_dir"

  # Rewrite frontmatter name for suffixed channels.
  if [ -n "$suffix" ]; then
    # Replace the first occurrence of "name: <short_name>" in the frontmatter.
    # SKILL.md frontmatter is at the top; sed targets the first match.
    python3 - "$stage_dir/SKILL.md" "$short_name" "$archive_name" <<'PY'
import sys, pathlib
path, short, full = sys.argv[1], sys.argv[2], sys.argv[3]
p = pathlib.Path(path)
text = p.read_text()
needle = f"\nname: {short}\n"
replacement = f"\nname: {full}\n"
if needle not in text:
    sys.exit(f"expected frontmatter '{needle.strip()}' in {path}")
p.write_text(text.replace(needle, replacement, 1))
PY
  fi

  # Generate README.md linking to DESIGN.md.
  group="${SKILL_GROUP[$short_name]:-}"
  if [ -n "$group" ] && [ -f "design/$group/DESIGN.md" ]; then
    cat > "$stage_dir/README.md" <<EOF
# $archive_name

Part of [ddaanet/skills]($REPO_URL).
Design decisions: [$group/DESIGN.md]($REPO_URL/blob/main/design/$group/DESIGN.md)
EOF
  fi

  echo "📦 $archive_name"

  (cd "$stage_root" && zip -r -q - "$archive_name" \
    -x '*.DS_Store' -x '*__pycache__*' -x '*.pyc' \
  ) > "$DIST/${archive_name}.skill"

  rm -rf "$stage_dir"
  count=$((count + 1))
done < <(find . -name SKILL.md -not -path './dist/*' | sort)

echo ""
echo "Built $count skills in $DIST/"
ls -la "$DIST/"
```

- [ ] **Step 2: Make sure it's executable**

```bash
chmod +x build.sh
```

- [ ] **Step 3: Smoke test**

```bash
./build.sh
```

Expected `dist/` contents:
- `brief-en.skill`
- `brief-fr.skill`
- `preflight-en.skill`
- `preflight-fr.skill`
- `bilingual-skill-creator-en.skill`
- `handoff.skill`
- `passation.skill`

(7 files.)

- [ ] **Step 4: Peek inside one archive to confirm the rewrite**

```bash
unzip -p dist/brief-en.skill brief-en/SKILL.md | head -5
```
Expected first lines include `name: brief-en` (not `brief`) and the top-level archive dir is `brief-en/`.

```bash
unzip -p dist/handoff.skill handoff/SKILL.md | head -5
```
Expected: `name: handoff` (untouched).

- [ ] **Step 5: Commit**

```bash
git add build.sh
git commit -m "$(cat <<'EOF'
♻️ build.sh: classify by plugin path, rewrite for claude.ai

Plugin-short names stay short inside the repo; the archive builder
injects -en / -fr suffixes into the frontmatter and top-level dir so
the flat claude.ai namespace stays unambiguous. skills/ at repo root
ships as-is.
EOF
)"
```

---

## Task 7: Update `CLAUDE.md`

**Files:**
- Modify: `CLAUDE.md` (arborescence block and contenu table)

- [ ] **Step 1: Rewrite the arborescence block**

Replace the current `## Arborescence` section's code block with:

```
plugins/
  ddaa/                          # plugin Claude Code — EN
    .claude-plugin/plugin.json
    skills/
      brief/
      preflight/
      bilingual-skill-creator/
  ddaa-fr/                       # plugin Claude Code — FR
    .claude-plugin/plugin.json
    skills/
      brief/
      preflight/
skills/                          # claude.ai uniquement, hors plugin
  handoff/
  passation/
design/
  brief/DESIGN.md
  preflight/DESIGN.md
  handoff/DESIGN.md
  bilingual-skill-creator/DESIGN.md
build.sh
```

- [ ] **Step 2: Rewrite the contenu table**

Replace the current table with:

```
| Groupe | Skills | Plugin Claude Code | Description |
|--------|--------|--------------------|-------------|
| brief | brief (EN), brief (FR) | ddaa, ddaa-fr | Document de mission pour Claude Code |
| preflight | preflight (EN), preflight (FR) | ddaa, ddaa-fr | Validation pré-release |
| bilingual-skill-creator | bilingual-skill-creator | ddaa | Créer un skill en deux langues |
| handoff | handoff (EN), passation (FR) | — (claude.ai seul) | Résumé de fin de session |
```

- [ ] **Step 3: Update the Conventions section's `Plugin :` bullet and the arborescence lead-in if they reference `ddaanet` or the old single-plugin model.**

Specifically, replace:

> `**Plugin :** ddaanet — même repo sert de plugin Claude Code`

with:

> `**Plugins :** ddaa (EN), ddaa-fr (FR) — sous-dossiers de plugins/, auto-découverte skills/*/SKILL.md dans chacun.`

Update any other stale phrasing (e.g. references to `proof` / `relecture` in the Contenu paragraph).

- [ ] **Step 4: Commit**

```bash
git add CLAUDE.md
git commit -m "$(cat <<'EOF'
📝 CLAUDE.md: refléter split ddaa / ddaa-fr

Mise à jour arborescence et table des skills après déménagement dans
plugins/. Suppression de proof/relecture.
EOF
)"
```

---

## Task 8: Update `README.md`

**Files:**
- Modify: `README.md`

The README is bilingual (EN-first, FR second). Both halves need the same updates.

- [ ] **Step 1: Update the EN Skills table**

Drop the `proof`, `handoff`, `passation` rows from the top table (or move `handoff`/`passation` to a separate "claude.ai-only" subsection below). Update remaining paths from `skills/brief-en/` to `plugins/ddaa/skills/brief/`, etc.

Final EN Skills table should list:

```
| Skill | Plugin | Language | What it does |
|-------|--------|----------|--------------|
| brief | ddaa / ddaa-fr | EN / FR | Mission document for Claude Code |
| preflight | ddaa / ddaa-fr | EN / FR | Pre-release validation |
| bilingual-skill-creator | ddaa | EN | Create a skill in two languages |
```

Add below:

```
### claude.ai-only skills

These are not distributed via the Claude Code plugin; install the `.skill` archive from [Releases](https://github.com/ddaanet/skills/releases) instead.

| Skill | Language | What it does |
|-------|----------|--------------|
| handoff | EN | Session wrap-up to continue in a new chat |
| passation | FR | Résumé de fin de session |
```

- [ ] **Step 2: Update the Install / Claude Code section**

Replace the current single-plugin command with one that reflects the marketplace-based install (both plugins available separately). Example:

```
### Claude Code (plugin)

Through the ddaanet marketplace:

\`\`\`bash
claude /plugin marketplace add ddaanet/claude-plugins
claude /plugin install ddaa@ddaanet       # English
claude /plugin install ddaa-fr@ddaanet    # French
\`\`\`
```

- [ ] **Step 3: Update the FR mirror**

Apply the same structural changes to the FR section of the README.

- [ ] **Step 4: Update the Structure paragraph**

Replace the current description ("Skills live in `skills/*/SKILL.md`...") with the new layout summary referencing `plugins/` subdirs.

- [ ] **Step 5: Commit**

```bash
git add README.md
git commit -m "$(cat <<'EOF'
📝 README: split install instructions, flag claude.ai-only skills

Deux plugins Claude Code (ddaa / ddaa-fr) installés séparément via le
marketplace. handoff / passation restent distribués comme .skill
claude.ai uniquement.
EOF
)"
```

---

## Task 9: Update marketplace (separate repo `ddaanet/claude-plugins`)

**Files (in `/Users/david/code/claude-plugins/`):**
- Modify: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Replace the single `ddaa` entry with two entries**

In `/Users/david/code/claude-plugins/.claude-plugin/marketplace.json`, remove the existing `ddaa` block and insert:

```json
{
  "name": "ddaa",
  "source": {
    "source": "github",
    "repo": "ddaanet/skills",
    "path": "plugins/ddaa"
  },
  "description": "Skills — brief, preflight, bilingual skill creator (English).",
  "version": "0.1.0",
  "author": { "name": "David Allouche" },
  "repository": "https://github.com/ddaanet/skills",
  "license": "MIT",
  "keywords": ["brief", "preflight", "skill-creator", "english"]
},
{
  "name": "ddaa-fr",
  "source": {
    "source": "github",
    "repo": "ddaanet/skills",
    "path": "plugins/ddaa-fr"
  },
  "description": "Skills — brief, preflight (français).",
  "version": "0.1.0",
  "author": { "name": "David Allouche" },
  "repository": "https://github.com/ddaanet/skills",
  "license": "MIT",
  "keywords": ["brief", "preflight", "french", "français"]
}
```

- [ ] **Step 2: Validate JSON**

```bash
cd /Users/david/code/claude-plugins
python3 -c "import json; json.load(open('.claude-plugin/marketplace.json'))"
```
Expected: no output (exit 0).

- [ ] **Step 3: Commit in that repo**

```bash
cd /Users/david/code/claude-plugins
git add .claude-plugin/marketplace.json
git commit -m "$(cat <<'EOF'
♻️ split ddaa entry into ddaa (EN) + ddaa-fr (FR)

Matches the new plugin layout in ddaanet/skills where each language
is a subdir plugin under plugins/.
EOF
)"
```

(Do not push either repo — the user will push when satisfied.)

---

## Task 10: Final sanity check

- [ ] **Step 1: In the skills repo, confirm the shape**

```bash
cd /Users/david/code/skills
find plugins skills design -maxdepth 3 -type f -name "SKILL.md" -o -name "plugin.json" -o -name "DESIGN.md" | sort
```

Expected lines (in some order):
```
design/bilingual-skill-creator/DESIGN.md
design/brief/DESIGN.md
design/handoff/DESIGN.md
design/preflight/DESIGN.md
plugins/ddaa-fr/.claude-plugin/plugin.json
plugins/ddaa-fr/skills/brief/SKILL.md
plugins/ddaa-fr/skills/preflight/SKILL.md
plugins/ddaa/.claude-plugin/plugin.json
plugins/ddaa/skills/bilingual-skill-creator/SKILL.md
plugins/ddaa/skills/brief/SKILL.md
plugins/ddaa/skills/preflight/SKILL.md
skills/handoff/SKILL.md
skills/passation/SKILL.md
```

- [ ] **Step 2: Confirm the old root plugin manifest is gone**

```bash
test ! -e .claude-plugin
```
Expected: exit 0.

- [ ] **Step 3: Final build**

```bash
./build.sh
```
Expected 7 `.skill` files in `dist/`.

- [ ] **Step 4: Confirm git is clean**

```bash
git status
```
Expected: no tracked changes (everything committed).

No commit for this task — it's purely verification.

---

## Notes

- `git mv` preserves history across the rename. If any step accidentally uses plain `mv`, a follow-up `git add -A` still records the change but loses cross-file blame — prefer `git mv`.
- Do not push either repo as part of this plan. The user pushes when they choose.
- The `ddaanet/handoff` repo (the Stop-hook tool) is a different project and is not touched by this plan.
