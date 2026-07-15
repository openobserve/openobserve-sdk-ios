#!/usr/bin/env bash
# Zero-Datadog gate (doc 08 §5) for the iOS fork. Fails if shipped Swift Sources
# carry a Datadog identity/wire token. Excludes rebrand tooling, .build, and
# Apache-2.0 §4 per-file attribution headers (retained, verified by check-attribution).
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
PATHS=$(git ls-files 'OpenObserve*/Sources/*' 'Sources/*' 2>/dev/null || true)
[ -n "$PATHS" ] || { echo "no shipped sources?"; exit 1; }
HITS=$(echo "$PATHS" | xargs grep -nE \
  '\bDatadog[A-Za-z]|\bDATADOG|datad0g|ddog-gov|\bddtags\b|\bddsource\b|DD-API-KEY|com\.datadoghq' \
  2>/dev/null | grep -viE 'developed at Datadog|Copyright .*Datadog|licensed under' || true)
if [ -n "$HITS" ]; then
  echo "ZERO-DATADOG GATE FAILED — Datadog token in shipped Swift Sources:"
  echo "$HITS" | head -40; echo "total: $(echo "$HITS" | wc -l | tr -d ' ')"
  exit 1
fi
echo "zero-Datadog gate: PASS (shipped Swift Sources clean)"
