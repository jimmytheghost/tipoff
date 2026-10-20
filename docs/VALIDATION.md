# Validation — October 20, 2026

Environment: Apple Silicon macOS, Apple Swift 6.3.3, standalone Command Line Tools. Initial personal-use time zone: America/Denver.

## Executed

- `swift build`: passed.
- `scripts/test.sh`: **15 tests executed, 15 passed**. Covers live-source fixtures, streaming/radio decoding, rejection of challenge/wrong-date/paginated data, legitimate empty days, ESPN minute-precision timestamps, timezone/DST boundaries, cache isolation/corruption, preservation of offline data, stale async response rejection, postponements, and exclusion of scores from persisted models.
- `scripts/package-app.sh`: release app built and code signature verified. Packaged bundle approximately 1.1 MB. Info.plist validation passed.
- Live `TipoffCheck 2026-10-20`: NBA.com primary succeeded, 3 games; Peacock and NBC for each. Mountain start times: 1:00 PM, 5:00 PM, 7:30 PM. No fallback was needed.
- Live `TipoffCheck 2026-10-21`: NBA.com primary succeeded, 11 games. Source-provided national, subscription, and radio listings parsed.
- Direct Swift URLSession request to NBA CDN schedule endpoint returned HTTP 403. The accessible NBA Games page is used instead.
- Offscreen AppKit/SwiftUI renders inspected in dark and light appearances: all three opening-day games visible, source/time freshness footer visible, no clipping. Final dark preview: `docs/preview.png`.
- Installed `/Users/jimmytheghost/Applications/Tipoff.app`, verified its signature, launched it, and confirmed its executable remained running.

## Remaining hands-on checks

- Click the actual menu bar icon and exercise previous/next day, radio expansion, refresh, and Settings. Native UI automation timed out on the windowless menu bar app, so this was not verified through automated clicks.
- Enable launch at login and verify after a real login; left off during development.
- Exercise real sleep/wake, a real system timezone change, and network loss/recovery with the installed app. Offline preservation and request races passed automated tests.
- ESPN fallback decoder passed recorded live-fixture tests; a forced NBA outage with the installed app was not performed.

## Known limits

Website endpoints are undocumented and can change. NBA.com itself omitted local TV listings for several upcoming games in the samples; ESPN also omitted some local/streaming options. No source can presently be claimed complete or covered by an availability SLA. Tipoff only shows supplied listings and does not infer subscription or blackout eligibility. Deferred: broadcaster watch links, global regions, and additional sports.
