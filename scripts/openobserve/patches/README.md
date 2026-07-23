# patches/

Applied by `sync-upstream.sh` (with `git apply --3way`) AFTER the rebrand codemod, in
filename order. The codemod reproduces every *string* and *path* rename; these patches
carry only what it cannot express, so a fresh upstream sync reproduces the fork exactly.

Verified: sync from `UPSTREAM_BASE` + rebrand + these patches == the `openobserve`
branch, with **zero drift**.

## 0001-remove-datadog-xcworkspace.patch
Deletes `Datadog.xcworkspace` (2 files). A codemod renames; it cannot delete.

Root cause worth understanding before "fixing" this: the workspace is not merely
Datadog-named, it is **broken by the rebrand**. Its `contents.xcworkspacedata` is a
tracked text file, so the content rules rewrite its FileRef to
`group:OpenObserve/OpenObserve.xcodeproj` — but the project directory itself is
skipped by `pathRenames.skip` and stays `OpenObserve/Datadog.xcodeproj`. The result is
a workspace pointing at a path that does not exist, which hijacks
`xcodebuild -scheme` resolution away from `Package.swift`. Deleting it restores the
SPM build that `publish.sh` verifies.

(The `SKIP` regex in rebrand.mjs — `/(^|\/)\.(xcodeproj|xcworkspace)\//` — does NOT
guard these: it needs a literal `.xcodeproj/` after `^` or `/`, but the real
directories are named `Datadog.xcodeproj`, so the guard never fires.)

**The proper long-term fix is Option B, deliberately deferred:** rename both
`Datadog.xcworkspace` -> `OpenObserve.xcworkspace` and `OpenObserve/Datadog.xcodeproj`
-> `OpenObserve/OpenObserve.xcodeproj`. That REPAIRS the dangling FileRef and removes
the last Datadog-named paths from the repo. It is not done here because it repoints
`xcodebuild -scheme` from the verified Package.swift path to the Xcode project path —
a build-system change that must be validated on its own, not smuggled into a release.

## Not patched — generated at release time
- `*.podspec` `s.version` is stamped by `publish.sh` (`perl -0pi -e 's/s\.version.../'`).
  Never patch it; the fork's committed value is just whatever was last released.
- `api-surface-swift` / `api-surface-objc` are `make api-surface` output. **Run it after every
  sync and commit the result.** These are the only expected content drift besides the podspec
  version — a sync reproduces everything else byte-for-byte.

  They matter more than typical generated files: the surface records public declarations *with
  their default values*, so a behavioural change made in a patch does not appear here until the
  generator re-runs. A freshly synced tree therefore still reads

  ```
  public let OpenObserveNTPServers = ["0.datadog.pool.ntp.org", ...]
  ```

  even though patches/0002 already replaced that list in `ServerOffsetPublisher.swift`. Nothing
  ships it — no podspec globs the repo root — but it is upstream identity sitting in a public
  repo. `check-no-datadog.sh` now scans these two files specifically (they fall outside its
  `*/Sources/*` glob) and fails with a pointer to `make api-surface`.

## Regenerating / adding a patch
Simulate a sync in a throwaway worktree, then diff against `openobserve`:
1. `git worktree add --detach /tmp/sim $(cat scripts/openobserve/UPSTREAM_BASE)`
2. overlay `scripts/openobserve`, restore keep-ours paths, then **copy the tooling in
   AFTER the keep-ours loop** — `keep-ours.txt` lists `scripts/openobserve`, so the
   restore clobbers any newer tooling you staged first (sync-upstream.sh copies from
   `$TOOLING` for exactly this reason);
3. `node scripts/openobserve/rebrand.mjs`;
4. diff vs `openobserve`, capture the delta, verify `git apply --check` + zero drift.
