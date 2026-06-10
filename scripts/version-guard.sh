#!/usr/bin/env bash
# PreToolUse hook (Write|Edit) for the skills-monorepo plugin manifests.
#
# Refuses any agent edit that changes the .version of a
# plugins/*/.claude-plugin/plugin.json. `just release` owns version bumps
# (both plugins in lockstep); hand-edits desync the manifests from the
# latest tag and the marketplace entry, and only surface at release time.
#
# Adapted from claude-plugin-dev's version-guard.sh for two (N) manifests.
# Note: this catches Write/Edit only. A `sed -i` via Bash slips past it —
# the backstop is `just release`'s "manifest must match latest tag" check.
#
# Mechanical: the agent is not involved.
set -euo pipefail

input="$(cat)"
file_path="$(jq -r '.tool_input.file_path // ""' <<<"$input")"
[[ -n "$file_path" ]] || exit 0

cwd="$(jq -r '.cwd // ""' <<<"$input")"
[[ -n "$cwd" ]] || cwd="$PWD"

target="$(realpath -m -- "$file_path")"

# Find which manifest (if any) this edit targets.
manifest=""
for m in "$cwd"/plugins/*/.claude-plugin/plugin.json; do
  [[ -f "$m" ]] || continue
  [[ "$target" == "$(realpath -m -- "$m")" ]] || continue
  manifest="$m"; break
done
[[ -n "$manifest" ]] || exit 0

current="$(jq -r '.version // ""' "$manifest" 2>/dev/null || echo "")"
[[ -n "$current" ]] || exit 0  # manifest unparseable; let the edit through.

tool_name="$(jq -r '.tool_name // ""' <<<"$input")"

proposed=""
case "$tool_name" in
  Write)
    proposed="$(jq -r '.tool_input.content // ""' <<<"$input" \
      | jq -r '.version // ""' 2>/dev/null || echo "")"
    ;;
  Edit)
    new_string="$(jq -r '.tool_input.new_string // ""' <<<"$input")"
    version_line="$(grep -oE '"version"[[:space:]]*:[[:space:]]*"[^"]+"' <<<"$new_string" | head -1 || true)"
    [[ -n "$version_line" ]] && proposed="$(sed -E 's/.*"([^"]+)"[[:space:]]*$/\1/' <<<"$version_line")"
    ;;
  *) exit 0 ;;
esac

[[ -z "$proposed" || "$proposed" == "$current" ]] && exit 0

read -r -d '' agent_reason <<EOF || true
plugin.json version edit refused: $current -> $proposed ($manifest).

Versions are owned by 'just release {patch|minor|major}', which bumps both
plugins in lockstep, commits, tags, pushes, and bumps the marketplace entries
in one step. Hand-edits desync the manifests from the latest tag and the
marketplace, and only get caught at release time.

To ship a release, run the recipe. Do not bypass this guard, modify the
recipe, or alter version state by other means.
EOF

human_msg="version-guard: blocked plugin.json version edit ($current -> $proposed)"

jq -nc --arg r "$agent_reason" --arg s "$human_msg" \
  '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $r}, systemMessage: $s}' >&2
exit 2
