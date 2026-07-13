# Functional patch series (openobserve-sdk-ios)

Empty at scaffold time. The one functional change beyond rebranding is the
OpenObserve-only intake in the per-feature request builders (doc 03 §5):

| Patch | Concern | State |
|-------|---------|-------|
| `01-openobserve-intake.patch` | Request builders default to OpenObserve `/rum`,`/logs`; **fail closed** if no custom endpoint (never a Datadog `site` fallback) | todo (author post-rebrand) |

Make patches **against the rebranded tree**, single-concern, numeric-prefixed.
`sync-upstream.sh` re-applies them 3-way. Create:
`git diff -- <path> > scripts/openobserve/patches/NN-name.patch`.
