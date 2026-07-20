#!/usr/bin/env bash
# Zero-Datadog gate (doc 08 §5) for the iOS fork. Fails if anything that SHIPS in a
# published pod carries a Datadog identity — in its CONTENT or in its PATH.
# Excludes rebrand tooling, .build, and Apache-2.0 §4 per-file attribution headers
# (retained deliberately; verified by check-attribution.mjs).
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

# Every podspec globs "<Pod>/Sources/**/*.swift", so the shipped set is */Sources/*.
# NOTE: this deliberately matches ANY */Sources — the previous glob was
# 'OpenObserve*/Sources/*', which silently skipped TestUtilities/Sources even though
# TestUtilities.podspec is published. A gate that misses a published pod is worse than
# no gate: it reports PASS.
PATHS=$(git ls-files '*/Sources/*' 'Sources/*' 2>/dev/null || true)
[ -n "$PATHS" ] || { echo "no shipped sources?"; exit 1; }

FAIL=0

# --- 1. PATHS -----------------------------------------------------------------
# CocoaPods ships the directory structure, so a dir named Datadog/ lands inside the
# published artifact even when every file's content is clean. This is exactly how
# OpenObserveInternal/Sources/NetworkInstrumentation/Datadog and
# TestUtilities/Sources/Mocks/Datadog* passed a content-only gate.
PATH_HITS=$(echo "$PATHS" | grep -iE '(^|/)datadog' || true)
if [ -n "$PATH_HITS" ]; then
  echo "ZERO-DATADOG GATE FAILED — Datadog-named PATH inside a published pod:"
  echo "$PATH_HITS" | head -40
  echo "total: $(echo "$PATH_HITS" | wc -l | tr -d ' ')"
  FAIL=1
fi

# --- 2. CONTENT ---------------------------------------------------------------
# NOTE: `datadog\.` (bare lowercase + dot) catches HOSTNAMES like the upstream NTP vendor zone
# `[0-3].datadog.pool.ntp.org`, which every other pattern here misses — they all require an
# uppercase letter or the `hq` suffix. That gap shipped a default-on DNS lookup naming the
# upstream vendor in the published Android alpha1. Do not remove it.
HITS=$(echo "$PATHS" | xargs grep -nE \
  '\bDatadog[A-Za-z]|\bDATADOG|datad0g|ddog-gov|\bddtags\b|\bddsource\b|DD-API-KEY|com\.datadoghq|\bdd=s:|\bdd=p:|datadog\.pool|datadog\.[a-z]+\.(org|com|net)' \
  2>/dev/null | grep -viE 'developed at Datadog|Copyright .*Datadog|licensed under' || true)
if [ -n "$HITS" ]; then
  echo "ZERO-DATADOG GATE FAILED — Datadog token in shipped source CONTENT:"
  echo "$HITS" | head -40
  echo "total: $(echo "$HITS" | wc -l | tr -d ' ')"
  FAIL=1
fi

# --- 3. PUBLISHED METADATA: no fabricated human identities --------------------
# The podspecs are what CocoaPods publishes. Upstream lists four named Datadog engineers as
# `s.authors`; the datadoghq.com -> openobserve.ai rule rewrote their EMAIL ADDRESSES, inventing
# contact details for real people who do not work here — inaccurate personal data and an implied
# endorsement. It shipped in 0.1.0-alpha.1 before anyone noticed, because the gate only ever read
# source, never the metadata we actually publish.
#
# `authors` is package-MAINTAINER metadata: it must name OpenObserve. Apache-2.0 attribution is a
# separate mechanism and is NOT touched here — it lives in the per-file headers, the Copyright
# lines, NOTICE and LICENSE, and is verified by check-attribution.mjs.
IDENT_HITS=$(grep -nE '"[^"]+"\s*=>\s*"[^"@]+@(datadoghq\.com|openobserve\.ai)"' ./*.podspec 2>/dev/null \
  | grep -viE '"OpenObserve"\s*=>\s*"info@openobserve\.ai"' || true)
if [ -n "$IDENT_HITS" ]; then
  echo "ZERO-DATADOG GATE FAILED — individual identity in published podspec metadata:"
  echo "$IDENT_HITS" | head -20
  echo "  s.authors must be the maintaining ORG: { \"OpenObserve\" => \"info@openobserve.ai\" }"
  echo "  Never an upstream engineer's name — neither with their real address (false endorsement)"
  echo "  nor rewritten to @openobserve.ai (fabricated personal data)."
  FAIL=1
fi

[ "$FAIL" = "0" ] || exit 1
echo "zero-Datadog gate: PASS (shipped pod sources + published metadata clean)"
