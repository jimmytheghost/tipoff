# Validation — October 24, 2026

Original macOS environment: Apple Silicon macOS, Apple Swift 6.3.3, standalone Command Line Tools. Windows checks use Windows x64 and .NET SDK 9.0.203. Initial personal-use time zone: America/Denver.

## Compact Windows header and Light / Dark appearance — October 24, 2026

- Reduced the guide header from 58 to 36 logical units, with an 18-unit logo, 13-point title, and vector gear icon in a borderless 28×28 target. Gear retains the Settings tooltip and accessible name.
- Added Light and Dark appearance options in Settings, immediate dynamic-resource updates, and current-user persistence in `HKCU\Software\Tipoff\Appearance`. Missing/invalid preferences use Light; save failures show an inline error. Read failures preserve the default and surface a warning. No automatic OS-theme matching is claimed.
- Compared native macOS SwiftUI semantic colors with `docs/current-preview.png` and sampled its actual pixels: dark window `#1E1E1E`, cards `#252525`, primary text `#F4F4F4`, secondary text `#A5A5A5`, bright mint text `#40F3DF`, and selected-tab fill `#70DDCE`. Native Windows title bars and tray menus retain OS styling. Light preserves the established high-contrast teal palette.
- Windows fixture runner: **29 tests executed, 29 passed**. Release WPF build passed with **0 warnings, 0 errors**. Final `scripts/package-windows.ps1` and current-user `scripts/install-windows.ps1 -NoLaunch` both passed. No new automated tests added for appearance-only changes; runtime UI and persistence checks exercise the production implementation.
- Used Windows computer-use tools to open the gear, switch Light → Dark → Light, and inspect both Settings and the guide. Restarted the installed app with Dark saved and verified the dark palette restored. Corrected a selected-tab contrast issue found during inspection. Verified expanded Altitude text, regional notes, freshness, and the themed scrollbar; scrolling reached the remaining games. Both modes fit the existing 360-unit guide. Reopened the installed app normally with Dark selected after inspection.
- No schedule/source/network/cache changes. macOS `scripts/test.sh` and `scripts/package-app.sh` require unavailable macOS/SwiftUI tooling and were not run here; no live-source check needed. Unrelated shell-script line-ending changes and the untracked banner remain outside this change.

## Windows borderless date arrows — October 24, 2026

- Matched the macOS `chevron.left` / `chevron.right` plain-button treatment with WPF vector paths and invisible 28×28 rectangular click targets. Removed text glyphs and visible fills/borders, including hover/press boxes. Hover and keyboard focus tint the icon; press feedback changes opacity. Previous/next tooltips and explicit accessible names are preserved.
- Windows fixture runner: **29 tests executed, 29 passed**. `scripts/package-windows.ps1`: **passed** after closing a development copy that locked the initial publish output. `scripts/install-windows.ps1 -NoLaunch`: **passed**, updating the stable current-user installation and Start Menu shortcut.
- Used Windows computer-use tools to inspect the installed app in inspection mode: both vector chevrons render without boxes. Clicking the invisible padding outside the left chevron moved October 24 to October 23; clicking Next day returned to October 24. The 360-unit guide and date/footer layout remain intact. No new automated tests added for this view-only styling change.
- No networking, schedule, or cache changes; no live-source check needed. macOS scripts were not run because macOS/SwiftUI tooling is unavailable on this Windows host. Reopened the installed app in normal tray mode after inspection.

## Windows Settings and startup repair — October 24, 2026

- Added a Settings button to the guide header and Settings / About Tipoff to the tray menu. Inspected the installed WPF screen using Windows computer-use tools: the 360-unit window fits the startup toggle, notification-area explanation, registration status, Windows Startup Apps shortcut, version 0.4.1, and personal-tool/MIT About text without clipping. Opened Settings through the guide's button.
- Startup status now compares the Run command with the current executable rather than accepting any nonempty Tipoff entry. The tray checkbox refreshes when opened. Startup read/write failures remain visible; Settings shows inline errors.
- Windows fixture runner: **29 tests executed, 29 passed**. `scripts/package-windows.ps1`: **passed** after correcting a compile-time WPF/WinForms `Color` ambiguity. `scripts/install-windows.ps1`: **passed** at the default current-user location, including Start Menu shortcut creation and app launch. Replaced the running temporary `dist/windows-install-smoke` copy with `%LOCALAPPDATA%\Programs\Tipoff\Tipoff.exe`.
- Exercised the actual Settings checkbox off and back on. Verified off removes the Run entry and stores preference 0; on stores preference 1 and the exact quoted installed-executable command with `--startup`. Left startup enabled. Restarted the installed executable with `--startup`; it remained responsive with no visible main window. Registration and this launch check are not proof of a successful boot/sign-in.
- No schedule, source, networking, or cache changes. macOS `scripts/test.sh` and `scripts/package-app.sh` require unavailable macOS/SwiftUI tooling and were not run on this Windows host; no live-source check was needed. A real Windows sign-out/sign-in remains a hands-on check.

## Agent-ready Windows installation — October 23, 2026

- Added `scripts/install-windows.ps1` as the canonical current-user install path. It checks for the .NET 9 SDK, rejects a filesystem-root target, stops an existing copy from the exact target path, packages the current x64 app, creates a Start Menu shortcut, and launches Tipoff so its Start with Windows registration records the stable installed executable.
- Added a concise `CLAUDE.md` that routes Claude to `AGENTS.md` and the installer without duplicating product rules. README now separates current Windows source installation from the older downloadable macOS `v0.2.0` release and includes a copyable agent instruction.
- Verified through GitHub CLI that `v0.2.0` remains the only and latest published release; it is correctly described as the older macOS NBA-only build. No Windows binary release or conventional signed installer is claimed.
- Windows fixture runner: **29 tests executed, 29 passed**. Ran the installer against isolated ignored paths with launch disabled; packaging and WPF compilation passed, the seven expected application/license files were present, and the generated Start Menu shortcut resolved to the isolated `Tipoff.exe`. The user's installed/running copy was not replaced during this check.

## Windows game-card text contrast — October 23, 2026

- Darkened the shared game-card text accent from bright mint `#19B98A` to deep teal `#087F5B` for broadcaster names, preferred-team labels, and the Altitude Details control. Selected-control borders retain the brighter mint, preserving the established palette without using it for small text.
- Calculated contrast against the `#F3F6F5` card surface: **4.60:1**. Windows fixture runner: **29 tests executed, 29 passed**. `scripts/package-windows.ps1`: **passed**, including WPF compilation.

## Windows routine disclaimer removal — October 23, 2026

- Removed the persistent limited-coverage banner from NFL, WNBA, NHL, and ESPN-fallback views. The footer still names the active source, including explicit ESPN fallback labels, without spending the compact content area on static caveats.
- Preserved visible messages for actual refresh failures, saved-data fallback, and Altitude supplement failures or mismatches. The snapshot's `LimitedCoverage` field remains intact for cache compatibility and command-line diagnostics; only the repetitive flyout presentation changed.
- Updated `AGENTS.md` so future work preserves source/fallback labeling without reintroducing routine UI disclaimers. Windows fixture runner: **29 tests executed, 29 passed**. `scripts/package-windows.ps1`: **passed**, including WPF compilation.

## Windows compact game cards — October 23, 2026

- Reduced game-card vertical padding from 10 to 3 logical units per side and inter-card spacing from 8 to 3. Team-line margins were removed, the preferred-team label moved into the time column, and empty preferred labels and game notices now collapse instead of reserving blank lines.
- Preserved the existing three-column team / time / broadcaster structure, 360-unit flyout width, typography hierarchy, mint preferred-team treatment, source-provided broadcaster wrapping, notices, and expandable Altitude details. Long team or broadcaster text and real game notices can still increase a card's height rather than being clipped.
- Windows fixture runner: **29 tests executed, 29 passed**. `scripts/package-windows.ps1`: **passed**, including WPF XAML compilation. The rebuilt packaged app launched and remained responsive; final density and wrapping across unusual long listings remain hands-on checks.

## Windows transparent basketball icon — October 23, 2026

- Replaced the generated dark Material Icons basketball with a transparent-background teal-and-charcoal basketball derived from the original Tipoff artwork. The rounded-square tile is absent; the dark seams remain opaque. The original `img/Tipoff.png` and the separate macOS icon pipeline are unchanged.
- `scripts/generate-windows-icon.ps1` now crops the source artwork's presentation padding, applies a circular edge clip, retains a small optical margin for the notification area, and emits the same nine PNG-backed ICO sizes from 16 through 256 pixels. `scripts/package-windows.ps1` reproduces the icon from `img/Tipoff-transparent.png`.
- The obsolete Google Material Icons attribution and packaged Apache icon license were removed because the Windows icon no longer uses that geometry. The historical license file remains in the repository.
- Inspected the actual 16, 32, and 256-pixel ICO frames: the smallest frame retains a recognizable teal basketball and dark seams; larger frames preserve the clean circular edge and transparent surround. Final notification-area appearance on the user's display remains a hands-on check.
- Windows fixture runner: **29 tests executed, 29 passed**. `scripts/package-windows.ps1`: **passed** and produced the framework-dependent x64 package with the regenerated icon and without the obsolete packaged icon license. The final packaged app remained responsive in hidden startup mode with its existing Run registration.
- The expanded flyout header now loads a dedicated 256×256 PNG instead of asking WPF to choose a frame from the ICO. High-quality downscaling renders it at the existing 30×30 layout size; the tray continues using the multi-frame ICO. The generator reproduces both assets from the same transparent source.

## Windows NBA ordering and launch at sign-in — October 23, 2026

- Ported the macOS national-broadcast-first NBA display ordering to Windows for both NBA.com and ESPN fallback identities. Source-listed National / Streaming video games lead; recognized national brands in ESPN's generic TV / streaming category also qualify. League Pass, NBA TV, radio, regional-only, and missing listings remain in the later group. Nuggets lead within each group, TBD games remain last within their group, and saved snapshots receive the display preference without changing serialized content, source, coverage, or freshness.
- Added current-user launch at sign-in. First launch writes a quoted packaged-executable command with `--startup` to `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`; startup launches remain hidden in the notification area. The checked `Start Tipoff with Windows` tray action supports an explicit opt-out and refreshes the executable path when enabled. Registration failures surface through a notification rather than preventing the schedule UI from opening.
- Windows fixture runner: **29 tests executed, 29 passed**. New coverage includes national classification, League Pass / NBA TV / radio / regional exclusions, primary and ESPN identities, Nuggets in national and non-national groups, time and TBD ordering, saved-snapshot serialization preservation, and WNBA isolation.
- `scripts/package-windows.ps1`: **passed** and produced the framework-dependent x64 app at `dist/windows/Tipoff.exe`. Starting that executable with `--startup` left the tray process running and created the expected quoted current-user Run entry. A real sign-out/sign-in cycle remains a hands-on check.
- Live Windows `Tipoff.Check nba 2026-10-23`: **NBA.com, 12 games**. Knicks at Celtics and Rockets at Spurs, both source-listed Prime Video games, appeared first at 5:00 PM and 7:30 PM Mountain; the ten League Pass games followed starting with Bulls at Bucks at 2:00 PM. Primary decoding succeeded. The initial sandboxed request could not resolve ESPN; the required unrestricted retry succeeded.
- At that validation step, the app icon was intentionally left unchanged for separate follow-up work; the completed icon update is recorded above.

## PC ordering handoff note — October 23, 2026

- Historical handoff record: documented the then-pending Windows port of macOS commit `ea9b6ce`, including implementation locations, ordering rules, saved-data requirements, and Windows validation commands. The completed port and current evidence are recorded above.
- Documentation-only change: **0 app tests executed**; reviewed content, relative file links, and diff whitespace. No rebuild required.

## macOS NBA national broadcast ordering — October 23, 2026

- NBA listings now put source-listed national TV/streaming games before League Pass, NBA TV, regional-only, and missing listings. Nuggets lead within each group; remaining games retain chronological order. ESPN fallback entries without a national category recognize ABC, ESPN variants, NBC, Peacock, and Prime variants. Radio does not affect priority. This does not determine actual League Pass eligibility or change source/coverage warnings.
- Display-only ordering applies to saved snapshots, including older NBA snapshots without an explicit guide, without changing game arrays, broadcasters, source, coverage flags, or freshness. At that validation step, other sports and the Windows app retained their existing ordering; Windows parity is recorded above.
- `scripts/test.sh`: **57 tests passed**, including four parameterized guide-switch cases (**60 individual test/case executions**). Added two regression tests covering national/streaming brands and categories, NBA TV/League Pass/radio/regional exclusions, primary and ESPN fallback identities, mixed national/League Pass listings, Nuggets priority within groups, chronological/TBD ordering, saved snapshot equality, and WNBA isolation. Updated the previous Nuggets-first test to exercise national Nuggets priority within the national group.
- `scripts/package-app.sh`: **passed**, including release build and strict code-signature verification. Output: ignored `dist/Tipoff.app`.
- Live `swift run TipoffCheck 2026-10-23`: **NBA.com, 12 games**, no limited-coverage flag. Knicks at Celtics (5:00 PM Mountain) and Rockets at Spurs (7:30 PM Mountain), both source-listed Prime Video games, appeared first; the ten League Pass listings followed, starting with Bulls at Bucks (2:00 PM). Fetching, decoding, and cache schema remain unchanged.
- README, plan, data notes, and settings wording updated; diff whitespace checked. No new release published or Windows parity claimed.

## Windows system-tray app

- Built a native C# / WPF companion under `Windows/`, targeting .NET 9 on Windows x64. The packaged flyout is 360 logical units wide, uses the Tipoff icon and mint/rounded-card treatment, opens on first launch, toggles from the tray icon, and exposes Open / Refresh / Quit tray actions. The macOS source and packaging remain separate.
- Simplified the shared header to the `Tipoff` name without a sport-specific viewing-guide subtitle, removed the `No scores. Just where to watch.` settings/tray slogan, and replaced the padded mint icon with a transparent full-bleed dark basketball. The first custom seam drawing was rejected during review and replaced with the recognizable eight-panel `sports_basketball` geometry from Google Material Icons. The Windows ICO contains nine PNG-backed sizes from 16 through 256 pixels and is regenerated by `scripts/package-windows.ps1`; the macOS generator uses the native basketball symbol in the same dark treatment. Attribution and the Apache 2.0 license are included in the repository and Windows package.
- Ported strict schedule-only models and decoders for NBA.com, ESPN NBA fallback, ESPN NFL/WNBA, NHL.com and MLB.com with ESPN fallback. Caches are isolated by sport, calendar day, and Windows time-zone ID under `%LOCALAPPDATA%\Tipoff\Schedules\Windows\`; failed refreshes preserve saved data and original freshness. The Windows app now also decodes Altitude’s Nuggets table, requires date/opponent/home-away/tipoff agreement, preserves regional footnotes and show times in expandable Details, and keeps its saved supplement and original timestamp separately at `%LOCALAPPDATA%\Tipoff\Altitude.Windows.json`.
- Windows fixture runner: **28 tests executed, 28 passed**. Coverage includes NBA page parsing and rejection cases, ESPN parsing, source broadcaster preservation, no-score serialization, local/Eastern source dates, Nuggets/Broncos/Avalanche/Rockies identity and priority, NHL country filtering, MLB TV/streaming brands and radio exclusion, cache isolation, the 85-row Altitude fixture, Mountain DST, network variants, regional notes, strict matching, duplicate suppression, malformed pages, score-free supplement serialization, and failed refreshes with and without saved supplement data.
- Live Windows `Tipoff.Check` results: focused Altitude page — **85 listings**; NBA `2026-10-24` — **NBA.com + Altitude, 8 games**, with Pelicans at Nuggets first and Altitude / Altitude+ / KTVD-20* / League Pass; NFL `2026-10-25` — **ESPN, 12 games**; WNBA `2026-06-21` — **ESPN, 3 games**; NHL `2026-10-22` — **NHL.com, 12 games**; MLB `2026-07-01` — **MLB.com, 14 games**. Source-provided broadcasters were printed; NBA/NHL/MLB primary sources decoded successfully and ESPN-only guides retained their coverage warning. The live check also exposed gzip transport handling required by Altitude’s current page response; automatic decompression is now enabled.
- `scripts/package-windows.ps1`: **passed** after the Altitude and branding changes and produced the ignored framework-dependent x64 output at `dist/windows/Tipoff.exe`, including the MIT license, notice, and Apache 2.0 icon license. The package requires the .NET 9 Desktop Runtime; no installer, signature, or public Windows release is claimed.
- Hands-on Windows inspection exercised initial NBA rendering, sport selection, loading state, NFL coverage warning, Sunday shortcut, scrolling, Denver-first ordering, source/freshness footer, and Quit. It exposed and led to fixes for NFL display re-sorting, Quit being intercepted by the hide-on-close guard, and loaded content expanding below the taskbar. The final packaged check showed Broncos first, kept the full footer on-screen after async loading, and exited cleanly.
- Fresh automated hands-on inspection of the Altitude Details expansion and simplified branding was attempted, but the configured Windows computer-control service was unavailable. The packaged XAML compiled cleanly and the icon artwork was inspected at 16, 64, and 256 pixels; checking the final live 360-unit layout and exercising Quit remain hands-on checks.
- The existing macOS `scripts/test.sh` and `scripts/package-app.sh` require macOS/SwiftUI tooling and were not executable on this Windows host. No Swift networking/source code changed; the latest recorded macOS validation below remains applicable.

## Windows documentation refresh

- Updated the README, product plan, data notes, and current Windows validation summary to describe the system-tray app, simplified branding, Altitude supplement, source-build limitations, icon generation, and Apache 2.0 attribution consistently.
- Preserved the original 2048×2048 app icon at `img/Tipoff.png`; the then-current dark, full-bleed Windows tray icon remained a separate generated platform asset. Its later replacement is recorded above. The older macOS screenshot is retained as a feature reference but removed from the README hero because it predates the simplified header.
- Markdown links, targeted wording, original PNG dimensions/transparency, and diff whitespace checked. **0 app tests executed** for this documentation-only change; no source, model, networking, cache, or packaging behavior changed.

## GitHub screenshot and documentation refresh

- Copied the user-provided October 22 screenshot unchanged to `docs/current-preview.png` (PNG, 968×1044); it was originally displayed in the README at 484 pixels wide with a dated caption and descriptive alternative text. It shows all five sport tabs, Nuggets emphasis, and the open broadcast details popover. Older previews remain available.
- Reviewed README scope, source/coverage limitations, build instructions, version 0.4.1 packaging metadata, and GitHub release state. The latest published download remains NBA-only v0.2.0; current five-sport code is available from source. No new binary release is claimed. Corrected the obsolete two-guide statement in `docs/DATA.md` and clarified the menu bar icon instruction.
- Updated the GitHub repository description to name NBA, NFL, WNBA, NHL, and MLB.
- Image copy hash, PNG dimensions, local documentation/image links, and diff whitespace checked. **0 app tests executed** for this screenshot/documentation-only change; no app rebuild or live source check required. The prior implementation validation below remains the latest app test evidence.

## Rockies and Avalanche preference — version 0.4.1

- Rockies games appear first within MLB and Avalanche games first within NHL, with mint outline and uppercase team label matching Nuggets/Broncos. Other games stay chronological; multiple preferred games retain their own time order. The display preference also applies to older saved snapshots without changing stored game arrays, broadcasters, source/coverage fields, or original freshness.
- `scripts/test.sh`: **55 tests passed**, including four parameterized guide-switch cases (**58 individual test/case executions**). Two new regression tests cover both venues, NHL/MLB primary and ESPN fallback identities, cross-sport isolation, saved snapshot round-trips, preserved data/freshness, multiple preferred games, and empty lists. Existing Nuggets/Broncos tests still pass.
- Live `TipoffCheck 2026-07-01 --mlb`: **MLB.com, 14 games**, Miami at Colorado displayed first at 6:40 PM local time with source-listed Rockies.TV; remaining games chronological. Live `TipoffCheck 2026-10-23 --nhl`: **NHL.com, 2 games**, Tampa Bay at Colorado displayed first at 7:00 PM, with source-listed The Spot / ALT. The check tool now prints the same display order as the UI.
- Inspected native dark/light renders of both preferred rows at the existing 360-point width. Team labels, mint outlines, source-provided long network names, coverage warning, and freshness footer fit without clipping. Updated `docs/mlb-preview.png` and `docs/nhl-preview.png`.
- `scripts/package-app.sh`: **passed**, release build and strict code-signature verification, **0.4.1 (8)**; packaged Info.plist lint passed. Relaunched the local packaged app for user testing. Source fetching/decoding and cache schema are unchanged; no viewing availability is inferred and no Avalanche/Altitude supplement is added.
- README, plan, data notes, and repository instructions updated. Local documentation links and diff whitespace checked before commit. App remains a personal tool shared as-is; no release publication is claimed.

## WNBA, NHL, MLB — version 0.4.0

- Added sports in the requested order: WNBA, NHL, MLB. The 360-point selector is now NBA / NFL / WNBA / NHL / MLB. WNBA uses ESPN; NHL and MLB use league feeds with labeled ESPN fallback. NBA/NFL caches and Nuggets/Broncos emphasis remain compatible; new guides have isolated cache prefixes and no team/sport identity collisions. Today applies to WNBA/NHL/MLB; Sunday remains NFL-only.
- `scripts/test.sh`: **53 tests passed** (Swift Testing summary), including **four executed cases** for the parameterized guide-switch/stale-response test. There are 52 ordinary tests plus four parameterized cases, or **56 individual executions**. Added 13 test functions beyond the 40-test baseline: WNBA fixtures, strict league/schema validation, empty/TBD/postponed days, local-midnight/duplicate handling, NHL source-day/count/country filtering and missing listings, MLB regional streaming names/radio exclusion, doubleheader identity, malformed/partial feeds, primary/fallback attribution, score-free caches, and saved freshness on total source failure. A malformed NHL schedule-state case initially revealed that an unknown state was accepted; the decoder now rejects unknown states and the final suite passed.
- Live WNBA `TipoffCheck 2026-06-21 --wnba`: **ESPN, 3 games**, with source-listed CBS/Paramount+, NBA TV/local networks, and ESPN/Disney+. Current-day `2026-10-22 --wnba`: **ESPN, 0 games**. Empty-day UI makes no season-ended or eligibility claim.
- Live NHL `TipoffCheck 2026-10-22 --nhl`: **NHL.com, 12 games**. US-tagged TV/streaming names retained, Canadian entries excluded, coverage warning visible. `2026-07-01 --nhl`: **NHL.com, 0 games**, accepted as a valid empty schedule.
- Live MLB `TipoffCheck 2026-07-01 --mlb`: **MLB.com, 14 games**, including source-provided Rockies.TV and regional networks. `2026-10-23 --mlb`: **MLB.com, 1 game**, with FOX / FOX ONE and Fox Deportes / FOX ONE. `2026-10-22 --mlb`: **MLB.com, 0 games**. Duplicate home/away entries for the same national network collapsed within their category. Unusual suspension/resumption cases still warrant publisher checks; no comprehensive resumption guarantee is made.
- Live regression NBA `2026-10-24`: **NBA.com + Altitude, 8 games**, matching Nuggets channels and time retained. NFL `2026-10-25 --nfl`: **ESPN, 12 games**, Broncos first. Source/network failure paths were exercised through URLProtocol, including malformed first-party responses falling back to ESPN and total failures preserving saved snapshots.
- Inspected native dark and light renders for populated WNBA, NHL and MLB views, plus the empty WNBA view. Five sport tabs, long teams/networks, scrolling, sport icons, coverage notice and freshness footer fit the existing layout. Dark artifacts: `docs/wnba-preview.png`, `docs/nhl-preview.png`, `docs/mlb-preview.png`. Also inspected a long regular-season MLB render with sponsor-bearing publisher names wrapping in the broadcaster column.
- `scripts/package-app.sh`: **passed**, release build and strict code-signature verification, **0.4.0 (7)**. `plutil -lint` passed; Mach-O executable confirmed **arm64**. Packaged NOTICE matches the updated source notice. App remains ad-hoc signed and not notarized. Local packaged app relaunched for user testing; no GitHub release publication is claimed.
- README, plan, source details, historical research status, repository instructions, and NOTICE updated. Checked local Markdown links, diff whitespace, and new fixture fields for absence of score/clock/standings/record/odds data. Only the minimal schedule/broadcast fields are retained in new fixtures.
- Remaining hands-on checks: interactive sport switching, scrolling, login/wake behavior, and local reception/subscription availability. No independent WNBA fallback or Avalanche/Altitude supplement is implemented. These are undocumented website dependencies with incomplete listing/rights coverage.

## Nuggets first with Broncos-style emphasis

- Nuggets games appear first in NBA with a mint outline and NUGGETS label matching the Broncos treatment. Other NBA games remain chronological. Display ordering also applies to existing saved snapshots without changing stored listings or freshness. NFL ordering remains unchanged.
- `scripts/test.sh`: **40 executed, 40 passed**. One new regression covers home/away Nuggets games from both NBA.com and ESPN, saved snapshot round-trips, preserved freshness/data, chronological remaining games, NFL identity/order, and empty schedules.
- `scripts/package-app.sh`: **passed**, including release build and strict signature verification.
- Live `.build/debug/TipoffCheck 2026-10-24`: **NBA.com + Altitude, 8 games**. Production-view dark/light renders show Pelicans at Nuggets first, with supplied Altitude channels, Details, and freshness information intact at the existing 360-point width. Dark preview: `docs/nuggets-first-preview.png`. Interactive menu bar behavior remains a hands-on check.
- README, plan, and settings text updated; diff whitespace checked before commit.

## PNG icon export

- Copied the highest-resolution existing icon asset to `img/Tipoff.png`; verified it matches the source byte-for-byte.
- `sips` confirmed PNG format, 2048×2048 pixels, and an alpha channel; visually inspected the exported icon.
- Diff/content checks passed. **0 tests executed** for this asset/documentation-only change; no app rebuild or live source check needed.

## Day navigation click targets

- Previous/next day buttons now use 28×28-point label frames with rectangular content shapes, so the empty area around each chevron accepts clicks. Chevron styling and the 360-point popover width remain intact.
- `scripts/test.sh`: **39 executed, 39 passed**. No new tests added for this small view-only change.
- `scripts/package-app.sh`: **passed**, including release build and strict signature verification.
- Live `TipoffCheck 2026-10-21`: **NBA.com, 11 games**. Inspected a native dark render of the updated view; date navigation and game layout fit without clipping. Interactive edge clicks remain a hands-on check.
- README and plan updated; diff whitespace checked before commit.

## WNBA / MLB / NHL source research

- Documentation-only investigation; runtime and packaged version remain 0.3.2. No app tests, package build, or `TipoffCheck` run was introduced for this research. The last executed implementation baseline remains **39 tests passed**.
- Direct HTTP/JSON probes verified ESPN feeds for all three sports, MLB's schedule/broadcast feed, NHL's week and Avalanche season feeds, and Altitude's `/avs-broadcasts` table. Several WNBA dates were checked so a single empty day was not mistaken for source failure. Tested candidate WNBA CDN URLs did not return usable JSON; no first-party WNBA JSON feed is claimed verified.
- Recorded exact sample dates, counts, endpoints, broadcaster differences, and implementation gaps in `docs/SOURCE-RESEARCH.md`. Raw responses stayed outside Git; only schedule-related observations are recorded. No new sport support, decoder test coverage, or availability guarantee is claimed.
- README and plan link the findings. Checked local documentation links and diff whitespace before commit.

## NFL Sunday shortcut — version 0.3.2

- NFL replaces the date navigation's Today action with Sunday, visible on non-Sunday dates including today. It jumps to the upcoming local Sunday relative to the current date (today if already Sunday), rather than a Sunday relative to a browsed historical/future date. Sunday views hide the shortcut. NBA retains Today.
- Date calculation uses calendar-day addition in the Mac's time zone. The selected Sunday remains selected when reopening/refreshing; normal today-following behavior still applies when the target is today.
- `scripts/test.sh`: **39 executed, 39 passed**. Two new tests cover weekday/Sunday behavior, local Saturday versus UTC Sunday, DST dates, New Year, and jumping from a distant browsed date.
- Live `TipoffCheck 2026-10-20 --nfl`: **0 games**. Live `TipoffCheck 2026-10-25 --nfl`: **12 games**, Denver first. Native renders inspected: Sunday action visible on October 20 and absent on October 25, with compact layout intact.
- `scripts/package-app.sh`: **passed**, release build and strict signature verification, version **0.3.2 (6)**. Relaunched the packaged local app for user testing. README and plan updated; local Markdown links and diff whitespace checked before commit.

## Broncos within NFL — version 0.3.1

- Only NBA and NFL remain in the top-level selector. Broncos matchups appear within NFL's selected-day schedule, with Denver first and a mint outline. Removed the separate Broncos window, team-schedule requests, decoder, and associated fixtures. Old window caches are ignored; existing NBA/NFL daily caches keep their keys.
- `scripts/test.sh`: **37 executed, 37 passed**. Removed four tests for the deleted team-schedule feature and added an explicit NBA/NFL-only guide test. Existing daily NFL decoder, malformed/schema-change, cache isolation, source-date/DST, score exclusion, failure, and stale-response tests still pass.
- Live `TipoffCheck 2026-10-25 --nfl`: **12 games**, Denver at Arizona first with ESPN-listed CBS and 2:05 PM local kickoff. Live `TipoffCheck 2026-10-24`: **NBA.com + Altitude, 8 games**, matching Nuggets supplement retained.
- Inspected dark and light native renders: only NBA/NFL tabs, Denver highlighted inside the NFL list, 360-point width, source/coverage/freshness information intact. Updated `docs/nfl-preview.png`. The older Broncos screenshot below documents the superseded 0.3.0 design.
- `scripts/package-app.sh`: **passed**, release build and strict signature verification; `plutil -lint` passed. Packaged **0.3.1 (5)** and relaunched the local `dist/Tipoff.app` for user testing. Interactive switching remains a user check.
- Updated README, plan, source documentation, and repository instructions. Local Markdown links and diff whitespace checked before commit.

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
