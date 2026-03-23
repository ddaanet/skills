#!/usr/bin/env bash
# Build all .skill files into dist/
# A .skill is a zip containing the skill directory (SKILL.md + references/).
# DESIGN.md lives at group level and is NOT included in the package.
# For grouped skills, a README.md is generated at build time with a link
# to the DESIGN.md on GitHub.
#
# Detection: any directory containing SKILL.md is a skill.

set -euo pipefail

REPO_URL="https://github.com/ddaanet/skills"
DIST="dist"
rm -rf "$DIST"
mkdir -p "$DIST"

count=0

while IFS= read -r skill_md; do
  skill_dir="$(dirname "$skill_md")"
  skill_name="$(basename "$skill_dir")"
  parent_dir="$(dirname "$skill_dir")"
  group="$(basename "$parent_dir")"
  output="$DIST/${skill_name}.skill"

  # Generate README.md for grouped skills (DESIGN.md is at group level)
  if [ -f "$parent_dir/DESIGN.md" ] && [ "$parent_dir" != "." ]; then
    cat > "$skill_dir/README.md" << EOF
# $skill_name

Part of [ddaanet/skills]($REPO_URL).
Design decisions: [$group/DESIGN.md]($REPO_URL/blob/main/$group/DESIGN.md)
EOF
  fi

  echo "📦 $skill_name"

  # Create zip relative to parent so archive contains skill_name/ as root
  (cd "$parent_dir" && zip -r -q - "$skill_name" \
    -x '*.DS_Store' -x '*__pycache__*' -x '*.pyc' \
  ) > "$output"

  # Clean up generated README
  rm -f "$skill_dir/README.md"

  count=$((count + 1))
done < <(find . -name SKILL.md -not -path './dist/*' | sort)

echo ""
echo "Built $count skills in $DIST/"
ls -la "$DIST/"
