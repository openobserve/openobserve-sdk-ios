#!/usr/bin/env bash
#
# OpenObserve openobserve-sdk-ios upstream sync.
# checkout upstream → keep-ours overlay → rebrand (git mv product dirs/podspecs +
# content) → re-apply patches/ → record base. Verify with swift build + pod lib lint.
set -euo pipefail

UPSTREAM_REMOTE=${UPSTREAM_REMOTE:-upstream}
BASE_BRANCH=${BASE_BRANCH:-openobserve}
cd "$(git rev-parse --show-toplevel)"

[ -z "$(git status --porcelain -uno)" ] || { echo "error: uncommitted changes" >&2; exit 1; }
git fetch "$UPSTREAM_REMOTE" --prune --tags --quiet

TOOLING=$(mktemp -d); trap 'rm -rf "$TOOLING"' EXIT
git show "$BASE_BRANCH:scripts/openobserve/rebrand.mjs"     > "$TOOLING/rebrand.mjs"
git show "$BASE_BRANCH:scripts/openobserve/rename-map.json" > "$TOOLING/rename-map.json"
git show "$BASE_BRANCH:scripts/openobserve/keep-ours.txt"   > "$TOOLING/keep-ours.txt"
CURRENT_BASE=$(git show "$BASE_BRANCH:scripts/openobserve/UPSTREAM_BASE" 2>/dev/null | tr -d '[:space:]' || echo none)

TARGET=$(git rev-parse --verify "${1:-$UPSTREAM_REMOTE/develop}^{commit}")
SHORT=$(git rev-parse --short "$TARGET")
[ "$TARGET" != "$CURRENT_BASE" ] || { echo "Already up to date with $SHORT."; exit 0; }

echo "Syncing upstream ${CURRENT_BASE:0:12} -> $TARGET"
git checkout -B "sync/upstream-$SHORT" "$BASE_BRANCH"
git rm -rfq . >/dev/null
git checkout "$TARGET" -- .
git clean -fd --quiet

grep -vE '^\s*(#|$)' "$TOOLING/keep-ours.txt" | while read -r p; do
  git cat-file -e "$BASE_BRANCH:$p" 2>/dev/null && { rm -rf "$p"; git checkout "$BASE_BRANCH" -- "$p"; }
done
cp "$TOOLING/rename-map.json" "$TOOLING/keep-ours.txt" scripts/openobserve/ 2>/dev/null || true
node "$TOOLING/rebrand.mjs"

if compgen -G "scripts/openobserve/patches/*.patch" > /dev/null; then
  for p in scripts/openobserve/patches/*.patch; do git apply --3way "$p" || { echo "patch $p failed" >&2; exit 2; }; done
fi

echo "$TARGET" > scripts/openobserve/UPSTREAM_BASE
# Apache-2.0 §4 attribution gate: fail the sync if Datadog attribution was erased.
node scripts/openobserve/check-attribution.mjs

git add -A
git commit --quiet -m "chore(sync): rebrand upstream dd-sdk-ios @$SHORT as OpenObserve"
echo "Sync branch ready. Run swift build + pod lib lint, push, open a PR against $BASE_BRANCH."
