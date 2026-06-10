# Release tooling for the skills monorepo (ddaa + ddaa-fr, lockstep).
#
# Adapted from claude-plugin-dev's release.just for this repo's shape:
# two subdir plugins sharing one version, a single repo tag vX.Y.Z, the
# `github` remote, and `git-subdir` marketplace entries. Deliberately NOT
# vendored via git-subtree — a single repo is not enough occurrences to
# justify generalizing the toolkit (the toolkit assumes one root manifest,
# one tag, an `origin` remote, and a `github`-source marketplace entry,
# none of which hold here).
#
# Required: bash, jq, git, gh. The marketplace repo path defaults to the
# sibling ../claude-plugins; override with MARKETPLACE_DIR.

remote := "github"
main_branch := "main"
marketplace_dir := env_var_or_default("MARKETPLACE_DIR", justfile_directory() / ".." / "claude-plugins")

# Plugins versioned in lockstep. Manifest: plugins/<name>/.claude-plugin/plugin.json
plugins := "ddaa ddaa-fr"

# Build all skills and validate both manifests; `release` depends on this.
precommit:
    bash build.sh > /dev/null
    jq . plugins/ddaa/.claude-plugin/plugin.json > /dev/null
    jq . plugins/ddaa-fr/.claude-plugin/plugin.json > /dev/null

# Validate state, bump both manifests to the same new version, commit, tag
# vX.Y.Z, push main + tag, create a GitHub release, then bump both
# marketplace entries and push that repo. A release without the marketplace
# bump is invisible to end-users, so the two are coupled here. Pass `--yes`
# as the second arg to skip the confirmation prompt.

# Release both plugins in lockstep (bump, tag, GitHub release, marketplace).
release bump='patch' yes='': precommit
    #!/usr/bin/env bash
    set -euo pipefail
    remote="{{remote}}"
    main_branch="{{main_branch}}"
    marketplace_dir="{{marketplace_dir}}"
    plugins=({{plugins}})

    # --- validate repo state ---
    git diff --quiet HEAD || { echo "error: uncommitted changes" >&2; exit 1; }
    branch=$(git symbolic-ref -q --short HEAD || echo "")
    [ "$branch" = "$main_branch" ] || { echo "error: must be on $main_branch (currently $branch)" >&2; exit 1; }

    # --- lockstep invariant: both manifests carry the same version ---
    versions=()
    for p in "${plugins[@]}"; do
      versions+=("$(jq -r .version "plugins/$p/.claude-plugin/plugin.json")")
    done
    version="${versions[0]}"
    for v in "${versions[@]}"; do
      [ "$v" = "$version" ] \
        || { echo "error: plugin versions diverge (${versions[*]}); lockstep release needs them equal" >&2; exit 1; }
    done

    # --- manifest must match latest tag (skipped until the first tag exists) ---
    latest_tag=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || true)
    if [ -n "$latest_tag" ] && [ "$version" != "$latest_tag" ]; then
      echo "error: plugin version ($version) does not match latest tag (v$latest_tag)" >&2
      echo "hint: manifests hold the LAST released version; the recipe bumps from there." >&2
      echo "      revert any manual version edit and re-run." >&2
      exit 1
    fi

    # --- marketplace pre-flight (fail fast, before any destructive op) ---
    marketplace_json="$marketplace_dir/.claude-plugin/marketplace.json"
    [ -f "$marketplace_json" ] \
      || { echo "error: $marketplace_json not found (set MARKETPLACE_DIR to the claude-plugins repo)" >&2; exit 1; }
    for p in "${plugins[@]}"; do
      jq -e --arg n "$p" 'any(.plugins[]; .name == $n)' "$marketplace_json" >/dev/null \
        || { echo "error: no marketplace entry for '$p' in $marketplace_json" >&2; exit 1; }
    done
    git -C "$marketplace_dir" diff --quiet HEAD \
      || { echo "error: $marketplace_dir has uncommitted changes" >&2; exit 1; }

    # --- compute new version ---
    new_version=$(jq -rn --arg v "$version" --arg bump "{{bump}}" '
      ($v | split(".") | map(tonumber)) as [$maj,$min,$pat]
      | if   $bump == "major" then [$maj+1, 0, 0]
        elif $bump == "minor" then [$maj, $min+1, 0]
        elif $bump == "patch" then [$maj, $min, $pat+1]
        else error("unknown bump type: " + $bump) end
      | map(tostring) | join(".")')
    tag="v$new_version"
    git rev-parse "$tag" >/dev/null 2>&1 && { echo "error: tag $tag already exists" >&2; exit 1; }

    if [ "{{yes}}" != "--yes" ]; then
      read -rp "Release ${plugins[*]} $version -> $new_version? [y/N] " ans
      case "$ans" in y|Y) ;; *) exit 1 ;; esac
    fi

    # --- bump manifests, commit, tag, push ---
    for p in "${plugins[@]}"; do
      m="plugins/$p/.claude-plugin/plugin.json"
      tmp=$(mktemp); jq --arg v "$new_version" '.version = $v' "$m" > "$tmp"; mv "$tmp" "$m"
      git add "$m"
    done
    git commit -m "release: $new_version"
    git tag -a "$tag" -m "Release $new_version"
    git push "$remote" "$main_branch"
    git push "$remote" "$tag"
    gh release create "$tag" --title "Release $new_version" --generate-notes

    # --- bump both marketplace entries, commit, push ---
    names_json=$(printf '%s\n' "${plugins[@]}" | jq -R . | jq -s .)
    tmp=$(mktemp)
    jq --argjson names "$names_json" --arg v "$new_version" '
      .plugins |= map(if (.name as $n | $names | index($n)) then .version = $v else . end)
    ' "$marketplace_json" > "$tmp"
    mv "$tmp" "$marketplace_json"
    git -C "$marketplace_dir" add .claude-plugin/marketplace.json
    # Idempotent: if the entries were already at $new_version, skip the commit
    # rather than let `git commit` exit 1 under `set -e` after the irreversible
    # push/tag steps.
    if git -C "$marketplace_dir" diff --cached --quiet; then
      echo "Release $tag complete (marketplace already at $new_version)"
    else
      git -C "$marketplace_dir" commit -m "release: ddaa/ddaa-fr $new_version"
      git -C "$marketplace_dir" push
      echo "Release $tag complete (marketplace bumped to $new_version)"
    fi
