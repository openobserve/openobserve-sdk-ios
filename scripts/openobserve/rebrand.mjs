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

const { rules, pathRenames, fileRenames = [] } = JSON.parse(fs.readFileSync(path.join(HERE, 'rename-map.json'), 'utf8'))
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
const applyRules = (s) =>
  s
    .split('\n')
    .map((line) =>
      ATTRIBUTION_RE.test(line)
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
if (CHECK && (changed > 0 || totalMoves > 0 || fileMoves > 0)) process.exit(1)
