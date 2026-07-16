#!/usr/bin/env bash
#
# OpenObserve iOS SDK — build, lint & publish (manual + CI/CD).
#
# Publishes the OpenObserve* pods to CocoaPods trunk IN DEPENDENCY ORDER
# (OpenObserveInternal is the base and must go first) and tags the repo for SPM.
# Safe by default: lints only, unless you pass --publish.
#
# USAGE
#   scripts/openobserve/publish.sh --version 0.1.0-alpha.1                # lint only (dry run)
#   scripts/openobserve/publish.sh --version 0.1.0-alpha.1 --publish      # -> CocoaPods trunk + git tag
#
#   --publish       push to trunk + create/push the git tag (omit = lint only)
#   --spm-only      just create/push the git tag (SPM consumers), skip CocoaPods
#
# REQUIRED ENV (only when --publish): COCOAPODS_TRUNK_TOKEN
# REQUIRED TOOLCHAIN: Xcode + `pod` (CocoaPods), git push access.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

VERSION="" ; PUBLISH=0 ; SPM_ONLY=0
while [ $# -gt 0 ]; do case "$1" in
  --version) VERSION="$2"; shift 2;;
  --publish) PUBLISH=1; shift;;
  --spm-only) SPM_ONLY=1; shift;;
  *) echo "unknown arg: $1" >&2; exit 2;;
esac; done
[ -n "$VERSION" ] || { echo "ERROR: --version X.Y.Z[-alpha.N] required" >&2; exit 2; }

# Publish order: base first, then Core, then the features. Every other pod declares
# exactly one local dependency — OpenObserveInternal — so this order is sufficient:
# once Internal is on trunk, each later pod resolves it from there.
# OpenObserveProfiling is included because upstream publishes DatadogProfiling; omitting
# it would ship 9 pods where upstream ships 10.
PODS=(
  OpenObserveInternal
  OpenObserveCore
  OpenObserveLogs OpenObserveTrace OpenObserveRUM OpenObserveCrashReporting
  OpenObserveSessionReplay OpenObserveWebViewTracking OpenObserveFlags
  OpenObserveProfiling
)

# Platforms to validate. The podspecs advertise ios + tvos + watchos, so all three are
# linted — publishing a platform we never built is an unvalidated claim to consumers.
# Requires the simulator runtimes: xcodebuild -downloadPlatform tvOS (and watchOS).
LINT_PLATFORMS=${LINT_PLATFORMS:-ios,tvos,watchos}

# Local podspecs a pod needs at lint time, BEFORE anything is on trunk.
# Deliberately minimal — do NOT use --include-podspecs='*.podspec'. CocoaPods cannot
# resolve the EXTERNAL transitive deps of *included* podspecs, so the glob pulled
# TestUtilities -> OpenObserveTrace -> OpenTelemetry-Swift-Api into every lint graph and
# failed with "Unable to find a specification for OpenTelemetry-Swift-Api (~> 2.3.0)" —
# even while that pod resolves fine on its own, and even when linting dependency-free
# OpenObserveInternal. Passing --sources does not help. Including only the real local
# dep keeps external deps owned by the pod UNDER TEST, where they resolve normally.
lint_includes() {
  case "$1" in
    OpenObserveInternal) echo "" ;;                                  # no dependencies
    *)                   echo "--include-podspecs=OpenObserveInternal.podspec" ;;
  esac
}

echo "==> OpenObserve iOS publish: $VERSION (publish=$PUBLISH, spm-only=$SPM_ONLY)"

# --- 1. set version in every podspec ------------------------------------------
for p in *.podspec; do
  perl -0pi -e "s/s\\.version\\s*=\\s*\"[^\"]*\"/s.version      = \"$VERSION\"/" "$p"
done
echo "    set s.version = \"$VERSION\" in $(ls *.podspec | wc -l | tr -d ' ') podspecs"

# --- 2. release gates ---------------------------------------------------------
echo "==> gate: zero-Datadog (shipped Swift sources)"
scripts/openobserve/check-no-datadog.sh || { echo "FAILED zero-Datadog gate" >&2; exit 1; }
[ -f scripts/openobserve/check-attribution.mjs ] && node scripts/openobserve/check-attribution.mjs || true

# --- 3. build-verify (iOS destination — swift build can't target UIKit) -------
echo "==> xcodebuild (iOS Simulator) — build the umbrella scheme"
xcodebuild -scheme OpenObserveRUM -destination 'generic/platform=iOS' build \
  | { xcpretty 2>/dev/null || cat; }

if [ "$SPM_ONLY" = "0" ]; then
  echo "==> pod lib lint (each pod, dependency order, platforms=$LINT_PLATFORMS)"
  for pod in "${PODS[@]}"; do
    echo "    lint $pod"
    # shellcheck disable=SC2046  # word-splitting of lint_includes is intentional
    pod lib lint "$pod.podspec" --allow-warnings --platforms="$LINT_PLATFORMS" $(lint_includes "$pod") \
      || { echo "FAILED: $pod did not pass lint" >&2; exit 1; }
  done
fi

# --- 4. publish ---------------------------------------------------------------
if [ "$PUBLISH" = "0" ]; then
  echo "OK (dry run: lint only). Re-run with --publish to push to trunk + tag."
  exit 0
fi

echo "==> git tag $VERSION (SPM release)"
git tag -f "$VERSION"
git push -f origin "$VERSION"

if [ "$SPM_ONLY" = "0" ]; then
  : "${COCOAPODS_TRUNK_TOKEN:?set your CocoaPods trunk token}"
  echo "==> pod trunk push (dependency order — each waits for its deps on trunk)"
  for pod in "${PODS[@]}"; do
    echo "    push $pod"
    pod trunk push "$pod.podspec" --allow-warnings --synchronous
  done
fi
echo "OK. Published OpenObserve* $VERSION to CocoaPods trunk + tagged for SPM."
