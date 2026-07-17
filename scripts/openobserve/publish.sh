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

# --- 0. toolchain guard (fail FAST, before gates/build) -----------------------
# CocoaPods lives under Homebrew's prefix, which only reaches PATH via the user's
# profile. A NON-LOGIN shell — CI, cron, or any tool-invoked bash — does not source
# that profile, so `pod` resolves in an interactive terminal but not here. Left
# unguarded, publish.sh runs the gates and a full multi-platform xcodebuild (minutes)
# and only then dies with "pod: command not found" at the first lint. Resolve it now.
if ! command -v pod > /dev/null 2>&1; then
  for p in /opt/homebrew/bin /usr/local/bin; do
    if [ -x "$p/pod" ]; then export PATH="$p:$PATH"; break; fi
  done
fi
if [ "$SPM_ONLY" = "0" ] && ! command -v pod > /dev/null 2>&1; then
  echo "ERROR: CocoaPods (pod) not found in PATH." >&2
  echo "       Looked in: \$PATH, /opt/homebrew/bin, /usr/local/bin" >&2
  echo "       Install with 'brew install cocoapods', or re-run with --spm-only." >&2
  exit 2
fi
# xcodebuild needs full Xcode, not the CommandLineTools instance that `xcode-select`
# points at by default — otherwise every build fails with "requires Xcode, but active
# developer directory is a command line tools instance".
if ! xcodebuild -version > /dev/null 2>&1; then
  if [ -d /Applications/Xcode.app/Contents/Developer ]; then
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
  else
    echo "ERROR: xcodebuild requires full Xcode. Set DEVELOPER_DIR or run:" >&2
    echo "       sudo xcode-select -s /Applications/Xcode.app/Contents/Developer" >&2
    exit 2
  fi
fi
echo "    toolchain: $(pod --version 2>/dev/null || echo 'pod n/a (spm-only)') | Xcode $(xcodebuild -version 2>/dev/null | head -1 | awk '{print $2}')"

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

# Platforms to validate. Left EMPTY on purpose: `pod lib lint` already defaults to linting
# every platform a podspec declares, which is exactly the bar we want — validate everything
# we advertise, and nothing we don't. Do NOT hardcode a list here: the pods differ
# (SessionReplay and Profiling are ios+tvos; WebViewTracking is ios-only; the rest add
# watchos), so forcing ios,tvos,watchos on all of them fails with
# "Platform `watchOS` is not supported by specification `OpenObserveSessionReplay`".
# Requires the simulator runtimes to be installed for every declared platform
# (xcodebuild -downloadPlatform tvOS / watchOS) — a missing runtime, not a missing flag,
# is what makes a platform fail to lint.
# Override only to narrow scope during local iteration, e.g. LINT_PLATFORMS=ios.
LINT_PLATFORMS=${LINT_PLATFORMS:-}

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
  echo "==> pod lib lint (each pod, dependency order, platforms=${LINT_PLATFORMS:-<as declared by each podspec>})"
  PLATFORM_ARG=""
  [ -n "$LINT_PLATFORMS" ] && PLATFORM_ARG="--platforms=$LINT_PLATFORMS"
  for pod in "${PODS[@]}"; do
    echo "    lint $pod"
    # shellcheck disable=SC2046,SC2086  # word-splitting of the optional flags is intentional
    pod lib lint "$pod.podspec" --allow-warnings $PLATFORM_ARG $(lint_includes "$pod") \
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
  # Trunk auth comes from EITHER an explicit token (CI) or the ~/.netrc session written by
  # `pod trunk register` (local). Requiring the env var unconditionally would abort a local
  # publish that is in fact fully authenticated.
  if [ -z "${COCOAPODS_TRUNK_TOKEN:-}" ] && ! grep -q 'trunk.cocoapods.org' "${HOME}/.netrc" 2>/dev/null; then
    echo "ERROR: no CocoaPods trunk credentials." >&2
    echo "       Local:  pod trunk register you@openobserve.ai 'OpenObserve'  (then click the email link)" >&2
    echo "       CI:     export COCOAPODS_TRUNK_TOKEN=..." >&2
    exit 2
  fi
  echo "    trunk auth: ${COCOAPODS_TRUNK_TOKEN:+env token}${COCOAPODS_TRUNK_TOKEN:-~/.netrc session}"
  echo "==> pod trunk push (dependency order — each waits for its deps on trunk)"
  for pod in "${PODS[@]}"; do
    echo "    push $pod"
    pod trunk push "$pod.podspec" --allow-warnings --synchronous
  done
fi
echo "OK. Published OpenObserve* $VERSION to CocoaPods trunk + tagged for SPM."
