# Validation — October 20, 2026

Environment: Apple Silicon macOS, Apple Swift 6.3.3, standalone Command Line Tools. Initial personal-use time zone: America/Denver.

## NFL / Broncos — version 0.3.0

- `scripts/test.sh`: **40 executed, 40 passed** after the final source, test, and fixture changes (28 existing and 12 NFL/Broncos tests). New coverage includes real sanitized daily/team/preseason fixtures, source-listed broadcasters, wrong league/season/type, malformed entries and schema changes, valid empty schedules, TBD kickoffs, local-day filtering, Denver priority, 35-calendar-day windows across DST/New Year, guide cache isolation and legacy NBA snapshots, excluded score/clock/record fields, regional/radio handling, and stale response rejection with saved-cache preservation on failure.
- Live `TipoffCheck 2026-10-20 --broncos`: ESPN Broncos schedule, **4 games** in October 20–November 23. Dates: October 25, November 1, November 8, November 22. CBS listed directly by ESPN; no streaming or local affiliate added. Preseason, regular-season, and postseason requests completed. ESPN's root current-season phase differs from requested preseason metadata; validation uses the requested/event phase rather than assuming they match.
- Live `TipoffCheck 2026-10-25 --nfl`: ESPN NFL, **12 games**, Broncos at Cardinals first, 2:05 PM local time. Other games remain visible in time order after Denver. Coverage warning shown.
- Live regression `TipoffCheck 2026-10-24`: **NBA.com + Altitude, 8 games**. Pelicans at Nuggets at 7:00 PM local time still matches Altitude / Altitude+ / KTVD-20*.
- Inspected native SwiftUI dark and light renders for Broncos and NFL. Selector, dated Broncos rows, mint emphasis, coverage warning, source/freshness footer, and scrolling NFL list fit the 360-point layout. Dark artifacts: `docs/broncos-preview.png`, `docs/nfl-preview.png`. The check renderer now takes its selected date from the snapshot day so multi-day previews retain the correct window origin.
- `scripts/package-app.sh`: **passed**, release build and strict code-signature verification. Bundle metadata: **0.3.0 (4)**. `plutil -lint` passed; packaged executable confirmed **arm64**. Build is ad-hoc signed, not notarized. App output is in ignored `dist/Tipoff.app`; no installation or GitHub release publication is claimed.
- Documentation/diff/link checks passed. Fixtures retain public schedule fields only; no raw website response or telemetry is persisted by the app. Existing NBA caches keep their filenames; NFL and Broncos use separate prefixes under the shared 45-snapshot cap.
- Remaining manual checks: interactive menu bar switching/scrolling, launch-at-login approval and OS wake behavior. Rendering exercises the production views; URLProtocol and controlled-provider tests exercise failure/cancellation behavior. NFL currently has ESPN as its only source, and future unassigned matchups may be absent.

## Public-sharing review using Agentic Toolkit v0.2

- Applied the toolkit's `core/GITHUB-PROJECT-PAGES.md` version 0.2, from toolkit commit `8b30f57e79a7bb2d298f027c2db841dd1ba1463f`.
- Confirmed that the repository is already public and v0.2.0 is published with an Apple Silicon archive and checksums. Anonymous repository and release-download access returned HTTP 200.
- Reviewed the existing README, AGENTS.md, license/notice, source entry point, package/build metadata, validation notes, and existing open issues. No open GitHub issues were listed at this review; this is not a claim that the app is bug-free.
- Added the already-known upstream broadcast-coverage gaps to README's Known issues section, with a suggestion to check the broadcaster's own schedule for missing options.
- Changes are documentation-only. Runtime source, packaging, and resources match the v0.2.0 tag, so the existing release remains applicable. No new bug sweep, repair backlog, rebuild, or test run was introduced. The 28-test result below is the prior executed baseline.
- Checked documentation links, image references, and diff whitespace for the updated files. Review of the changed public text found no added personal data or credentials; the original publication's history review remains recorded below.

## Public sharing preparation — v0.2.0

- README rewritten for a personal tool shared as-is, with screenshots, source/build/install instructions, current scope, and clear Apple Silicon / ad-hoc signing / no-notarization limits. Detailed source documentation lives in `docs/DATA.md`.
- MIT license and third-party notice added; both are included in the packaged application.
- Scanned all 45 pre-publication historical file blobs for common credential formats and raw visitor metadata assignments; no matches. Reviewed tracked paths: no build outputs, schedule caches, signing material, or credentials are tracked. Original commit author names/emails remain in history.
- `scripts/test.sh`: **28 executed, 28 passed**. `scripts/package-app.sh`: passed; no runtime behavior changes in this preparation.
- Packaged `Tipoff-0.2.0-macos-arm64.zip` and `SHA256SUMS` for a basic GitHub release. Verified archive members, license/notice inclusion, extracted app code signature, and Mach-O arm64 architecture. No Intel or notarization claim is made.
- Local Markdown/image links and diff whitespace checks passed.

## Altitude Nuggets supplement — version 0.2.0

- `scripts/test.sh`: **28 executed, 28 passed** after the final changes. Includes 13 new Altitude cases: actual schedule fixture (85 dated games; unassigned Cup placeholders ignored), channel variants, neutral sites, national-only games, market notes, duplicate broadcasters, strict matchup/tipoff agreement, changed game suppression, Mountain DST, malformed pages/headers/missing footnotes, score-free cache round-trip, and failed-refresh handling with and without saved data.
- Live `TipoffCheck 2026-10-24`: NBA.com + Altitude, 8 games. Pelicans at Nuggets at 7:00 PM MDT matched; Altitude, Altitude+, KTVD-20*, regional note, pregame/postgame data loaded.
- Live `TipoffCheck 2026-10-28`: NBA.com + Altitude, 12 games. Nuggets at Pelicans at 6:00 PM MDT matched; Altitude 2, Altitude+, KTVD-20* loaded. Pregame 5:30 PM and postgame 8:30 PM MDT came directly from Altitude.
- Inspected native dark renders of the Nuggets row and its actual Details view: channels, regional footnote, times, and original Altitude check timestamp visible without clipping. Preview snapshot was filtered to the Nuggets game for visual review; the app still shows all games. Artifacts: `docs/altitude-preview.png`, `docs/altitude-details.png`.
- Fixture retains only the public raw schedule table inside a minimal page wrapper. No page visitor metadata, IP, or embedded service configuration is included.
- `scripts/package-app.sh`: release build and signature verification passed for 0.2.0; installed at `~/Applications/Tipoff.app` and relaunched.
- Actual popover interaction remains a hands-on check; renders use the same SwiftUI views. Source failures and saved-data behavior were exercised with URLProtocol responses, not by interrupting the user's connection.

## Layout update — version 0.1.1

- Radio hidden from the popover; retained only in the underlying source model.
- Each game is one row with three columns: stacked away/home teams, local start time, and TV/streaming listings. Team names replace redundant tricode labels in the compact layout.
- List height follows measured content, capped at 450 points before scrolling. Long team and broadcaster names wrap without truncation.
- `scripts/package-app.sh`: release build and signature verification passed; installed and relaunched `~/Applications/Tipoff.app` version 0.1.1.
- `scripts/test.sh`: **15 executed, 15 passed** after the final layout change. No new tests added for this visual change.
- Dark render inspected with the three opening-day games; light render inspected with synthetic long team/network names and multiple broadcast groups. No radio controls or clipped row content. Updated `docs/preview.png`.

## Initial build checks

- `swift build`: passed.
- `scripts/test.sh`: **15 tests executed, 15 passed**. Covers live-source fixtures, streaming/radio decoding, rejection of challenge/wrong-date/paginated data, legitimate empty days, ESPN minute-precision timestamps, timezone/DST boundaries, cache isolation/corruption, preservation of offline data, stale async response rejection, postponements, and exclusion of scores from persisted models.
- `scripts/package-app.sh`: release app built and code signature verified. Packaged bundle approximately 1.1 MB. Info.plist validation passed.
- Live `TipoffCheck 2026-10-20`: NBA.com primary succeeded, 3 games; Peacock and NBC for each. Mountain start times: 1:00 PM, 5:00 PM, 7:30 PM. No fallback was needed.
- Live `TipoffCheck 2026-10-21`: NBA.com primary succeeded, 11 games. Source-provided national, subscription, and radio listings parsed.
- Direct Swift URLSession request to NBA CDN schedule endpoint returned HTTP 403. The accessible NBA Games page is used instead.
- Offscreen AppKit/SwiftUI renders inspected in dark and light appearances: all three opening-day games visible, source/time freshness footer visible, no clipping. Final dark preview: `docs/preview.png`.
- Installed `~/Applications/Tipoff.app`, verified its signature, launched it, and confirmed its executable remained running.

## Remaining hands-on checks

- Click the actual menu bar icon and exercise previous/next day, refresh, and Settings. Native UI automation timed out on the windowless menu bar app, so this was not verified through automated clicks.
- Enable launch at login and verify after a real login; left off during development.
- Exercise real sleep/wake, a real system timezone change, and network loss/recovery with the installed app. Offline preservation and request races passed automated tests.
- ESPN fallback decoder passed recorded live-fixture tests; a forced NBA outage with the installed app was not performed.

## Known limits

Website endpoints are undocumented and can change. NBA.com itself omitted local TV listings for several upcoming games in the samples; ESPN also omitted some local/streaming options. No source can presently be claimed complete or covered by an availability SLA. Tipoff only shows supplied listings and does not infer subscription or blackout eligibility. Deferred: broadcaster watch links, global regions, and additional sports.
