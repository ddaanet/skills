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
  [proof]=proof
  [relecture]=proof
  [handoff]=handoff
  [passation]=handoff
)

stage_root="$(mktemp -d)"
trap 'rm -rf "$stage_root"' EXIT

count=0

while IFS= read -r skill_md; do
  src_dir="$(dirname "$skill_md")"
  short_name="$(basename "$src_dir")"

  case "$src_dir" in
    ./plugins/ddaa/skills/*)     suffix="-en" ;;
    ./plugins/ddaa-fr/skills/*)  suffix="-fr" ;;
    ./skills/*)                  suffix=""    ;;
    *) echo "⚠️  skipping $src_dir — unknown location"; continue ;;
  esac

  archive_name="${short_name}${suffix}"
  stage_dir="$stage_root/$archive_name"
  cp -r "$src_dir" "$stage_dir"

  if [ -n "$suffix" ]; then
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
