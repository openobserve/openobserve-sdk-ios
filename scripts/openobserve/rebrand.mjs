#!/usr/bin/env node
/**
 * OpenObserve rebrand codemod for the openobserve-sdk-ios fork.
 *
 * Two phases:
 *   1. topLevelPrefix path renames — git mv each top-level entry starting with
 *      "Datadog" (product dirs + *.podspec files) to "OpenObserve*". .xcworkspace/
 *      .xcodeproj are skipped (dev-only; renaming corrupts their internal refs).
 *   2. content rules — rewrite imports, Package.swift names, bundle ids, _dd.
 *
 *   node scripts/openobserve/rebrand.mjs           # apply
 *   node scripts/openobserve/rebrand.mjs --check    # report only
 *   node scripts/openobserve/rebrand.mjs --content-only
 *
 * NOTE: verify with `swift build` + `pod lib lint` — a missed import/module only
 * surfaces at compile time. Regenerate Datadog.xcworkspace if you need the IDE project.
 */
import { execFileSync } from 'child_process'
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

const ROOT = process.cwd()
const HERE = path.dirname(fileURLToPath(import.meta.url))
const CHECK = process.argv.includes('--check')
const CONTENT_ONLY = process.argv.includes('--content-only')
const LIST = process.argv.includes('--list')

const { rules, pathRenames, dirRenames = [], fileRenames = [] } = JSON.parse(
  fs.readFileSync(path.join(HERE, 'rename-map.json'), 'utf8')
)
const keepOursPaths = fs
  .readFileSync(path.join(HERE, 'keep-ours.txt'), 'utf8')
  .split('\n')
  .map((l) => l.trim())
  .filter((l) => l && !l.startsWith('#'))

const SKIP = [
  /(^|\/)\.git\//,
  /(^|\/)\.build\//,
  /(^|\/)build\//,
  /(^|\/)\.(xcodeproj|xcworkspace)\//,
  /^scripts\/openobserve\//,
  /\.(png|jpg|jpeg|gif|ico|svg|webp|woff2?|ttf|otf|a|framework|xcframework|zip|pdf|dSYM)$/i,
]

const git = (args) => execFileSync('git', args, { cwd: ROOT, maxBuffer: 256 * 1024 * 1024 }).toString('utf8')
const tracked = () => git(['ls-files', '-z']).split('\0').filter(Boolean)

function topLevelMoves(rule) {
  const skips = rule.skip || []
  const entries = new Set(tracked().filter((f) => !SKIP.some((re) => re.test(f))).map((f) => f.split('/')[0]))
  const moves = []
  for (const e of entries) {
    if (!e.startsWith(rule.topLevelPrefix)) continue
    if (skips.some((s) => e.endsWith(s))) continue
    moves.push([e, rule.to + e.slice(rule.topLevelPrefix.length)])
  }
  return moves
}

const compiled = rules.map((r) => ({ ...r, matcher: r.regex ? new RegExp(r.regex, 'g') : null }))
// Apache-2.0 §4(b)/(c): never rewrite upstream attribution lines — the per-file
// license header (in ANY comment style: /* */, #, <!-- ~ -->) and the third-party
// copyright manifest (LICENSE-3rdparty.csv). Matched by CONTENT, per line, so the
// Datadog->OpenObserve rules only touch code. Datadog's copyright/attribution stays
// verbatim; the OpenObserve modification statement lives in NOTICE + README (kept
// via keep-ours.txt).
const ATTRIBUTION_RE = /software developed at Datadog \(https:\/\/www\.datadoghq\.com\/\)|Copyright\b[^\n]*\bDatadog, Inc\./

// NEVER rewrite a real person's identity. The `datadoghq.com -> openobserve.ai` rule is right
// for URLs and WRONG for email addresses: upstream's podspecs list four named Datadog engineers
// as `s.authors`, and the rule silently rewrote e.g.
//   "Maciek Grzybowski" => "maciek.grzybowski@datadoghq.com"
//     ->                    "maciek.grzybowski@openobserve.ai"
// fabricating contact details for real people who do not work here and never consented. That
// shipped in the published 0.1.0-alpha.1 pods. It is inaccurate personal data (GDPR Art. 5(1)(d))
// and an implied endorsement — worse than either leaving it or removing it.
//
// Matching `"Name" => "local@datadoghq.com"` leaves the block EXACTLY as upstream wrote it, and
// patches/ then replaces the whole block with the OpenObserve organisation entry. Keeping the
// pre-image identical to upstream is what makes that patch stable across syncs.
//
// Guard the identity, not the file: a broad podspec skip would also miss real renames.
const PERSONAL_IDENTITY_RE = /"[^"]+"\s*=>\s*"[^"@]+@datadoghq\.com"/

const applyRules = (s) =>
  s
    .split('\n')
    .map((line) =>
      ATTRIBUTION_RE.test(line) || PERSONAL_IDENTITY_RE.test(line)
        ? line
        : compiled.reduce((out, r) => (r.matcher ? out.replace(r.matcher, r.to) : out.split(r.literal).join(r.to)), line)
    )
    .join('\n')

// ---- Phase 1: path renames --------------------------------------------------
let totalMoves = 0
for (const rule of pathRenames) {
  const moves = rule.topLevelPrefix ? topLevelMoves(rule) : []
  totalMoves += moves.length
  console.log(`pathRename [${rule.topLevelPrefix}*]: ${moves.length} top-level renames ${CHECK ? '(would run)' : ''}`)
  if (LIST) moves.forEach(([a, b]) => console.log(`  ${a} -> ${b}`))
  if (!CHECK && !CONTENT_ONLY) {
    for (const [from, to] of moves) git(['mv', from, to])
  }
}

// ---- Phase 1.2: nested directory renames (any depth) ------------------------
// topLevelMoves only inspects the FIRST path segment, so a Datadog-named directory
// nested at any depth was structurally unreachable — e.g.
//   OpenObserveInternal/Sources/NetworkInstrumentation/Datadog/   (SHIPPED in the pod)
//   TestUtilities/Sources/Mocks/DatadogCore/                      (SHIPPED in the pod)
// CocoaPods globs source_files as "**/*.swift", so those directory names ship inside
// the published artifact and break the zero-Datadog invariant even though every file's
// CONTENT is clean. Renames the basename of any tracked directory starting with the
// token, deepest paths handled by iterating to a fixpoint (a rename can expose a
// parent/child that still matches). Nested moves under an already-moved dir are
// dropped — git mv carries their content.
let dirMoves = 0
for (const rule of dirRenames) {
  const skips = rule.skip || []
  for (let pass = 0; pass < 10; pass++) {
    const dirs = new Set()
    for (const f of tracked().filter((x) => !SKIP.some((re) => re.test(x)))) {
      const parts = f.split('/')
      for (let i = 1; i < parts.length; i++) dirs.add(parts.slice(0, i).join('/'))
    }
    const moves = []
    for (const d of dirs) {
      const base = path.basename(d)
      if (!base.startsWith(rule.token)) continue
      if (skips.some((s) => d.includes(s))) continue
      if (keepOursPaths.some((p) => d === p || d.startsWith(`${p}/`))) continue
      moves.push([d, path.join(path.dirname(d), rule.to + base.slice(rule.token.length))])
    }
    // shallowest first, then drop any move nested under another move in this pass
    moves.sort((a, b) => a[0].split('/').length - b[0].split('/').length)
    const done = []
    const batch = moves.filter(([from]) => {
      if (done.some((p) => from === p || from.startsWith(`${p}/`))) return false
      done.push(from)
      return true
    })
    if (!batch.length) break
    dirMoves += batch.length
    if (LIST) batch.forEach(([a, b]) => console.log(`  ${a} -> ${b}`))
    if (CHECK || CONTENT_ONLY) break // no mutation: a second pass would report the same moves
    for (const [from, to] of batch) git(['mv', from, to])
  }
}
if (dirRenames.length) console.log(`dirRenames: ${dirMoves} directories ${CHECK ? 'would be' : ''} moved`)

// ---- Phase 1.5: file renames (basename token) -------------------------------
// Rename nested class-name FILES whose basename still carries a Datadog token
// (topLevelPrefix only moves top-level product dirs/podspecs). Literal token
// replacement on the basename only. Applied after Phase 1 so paths are final.
let fileMoves = 0
for (const rule of fileRenames) {
  for (const f of tracked().filter(
    (x) => !SKIP.some((re) => re.test(x)) && !keepOursPaths.some((p) => x === p || x.startsWith(`${p}/`))
  )) {
    const base = path.basename(f)
    if (!base.includes(rule.token)) continue
    const to = path.join(path.dirname(f), base.split(rule.token).join(rule.to))
    fileMoves++
    if (!CHECK && !CONTENT_ONLY) git(['mv', f, to])
  }
}
if (fileRenames.length) console.log(`fileRenames: ${fileMoves} files ${CHECK ? 'would be' : ''} moved`)

// ---- Phase 2: content -------------------------------------------------------
let changed = 0
for (const file of tracked().filter(
  (f) => !SKIP.some((re) => re.test(f)) && !keepOursPaths.some((p) => f === p || f.startsWith(`${p}/`))
)) {
  const abs = path.join(ROOT, file)
  let stat
  try {
    stat = fs.lstatSync(abs)
  } catch {
    continue
  }
  if (!stat.isFile()) continue
  const buf = fs.readFileSync(abs)
  if (buf.includes(0)) continue
  const content = buf.toString('utf8')
  const next = applyRules(content)
  if (next !== content) {
    changed++
    if (!CHECK) fs.writeFileSync(abs, next)
  }
}
console.log(`content: ${changed} files ${CHECK ? 'would be' : ''} rebranded`)
if (CHECK && (changed > 0 || totalMoves > 0 || dirMoves > 0 || fileMoves > 0)) process.exit(1)
