# Product plan

The [macOS feature screenshot](current-preview.png), captured October 22, 2026, shows the five-sport selector and Nuggets broadcast details in version 0.4.1 before the header branding was simplified. It is retained as a feature reference rather than presented as the current branding; older sport-specific previews remain available.

The original app icon remains exported to `img/Tipoff.png` as a reusable 2048×2048 PNG with transparency. Windows uses the freestanding teal-and-charcoal basketball extracted to `img/Tipoff-transparent.png`; packaging generates its multi-size tray ICO and a dedicated 256-pixel flyout-header PNG without the original rounded-square tile. The macOS icon remains separate.

## Windows system-tray app — October 2026

Implemented in `Windows/` as a package-free C# / WPF companion alongside the SwiftUI app. The Windows tray flyout keeps the 360-unit width, mint accent, rounded cards, five sport guides, local calendar-day navigation, NFL Sunday shortcut, Denver/Colorado display ordering, source/freshness labels, explicit fallback labels, and isolated saved snapshots. Text-facing accents inside game cards use the darker `#087F5B` teal against the light card surface; brighter mint remains available for selected borders and other non-text emphasis. Routine coverage disclaimers are omitted from the compact UI; actual refresh, saved-data, and Altitude problems remain visible. Game cards use compact vertical padding and spacing; empty preferred-team and game-notice fields collapse rather than leaving blank lines. Preferred labels share the time column so they do not push the team stack downward. Its shared branding is reduced to the Tipoff name and a freestanding teal-and-charcoal basketball mark, without the original rounded-square tile, sport-specific subtitles, or the former settings slogan. It ports the NBA.com / ESPN / NHL.com / MLB.com source hierarchy and projects only schedule and broadcaster fields into its model. Fixture tests explicitly verify that scores, clocks, periods, and standings do not enter serialized games.

The Windows app opens its flyout on a normal launch, toggles from the notification-area icon, and has Open / Refresh / Quit tray actions. After its first launch it starts hidden in the tray at Windows sign-in; a checked tray-menu option can disable or re-enable that current-user registration. It includes a Windows `Tipoff.Check`, a PowerShell packaging script, and a current-user installation helper that builds to `%LOCALAPPDATA%\Programs\Tipoff`, creates a Start Menu shortcut, and launches the stable installed executable. The output is currently a framework-dependent x64 source build requiring the .NET 9 SDK to install; no conventional signed installer or published Windows release is claimed. The Windows guide also carries the Nuggets Altitude supplement, strict schedule agreement, separate saved-data fallback, and expandable details for source networks, show times, regional notes, and freshness.

Still deferred from the Windows build: system dark-theme adaptation, Arm64 packaging, installer/signing, and automatic updates.

## Windows NBA ordering and startup — October 23, 2026

Implemented: ported macOS commit `ea9b6ce` to `Windows/Tipoff.Core/Models.cs` (`Game` and `ScheduleSnapshot.DisplayGames`) with regressions in `Windows/Tipoff.Tests/Program.cs`.

- Put source-listed National or Streaming video games (Prime, Peacock, ESPN, ABC, NBC, etc.) before League Pass, NBA TV, regional-only, and missing listings. Ignore radio. Match the macOS recognized-brand fallback for ESPN entries labeled only TV / streaming; see [display rules](DATA.md#nba-display-order).
- Keep Nuggets first within each group, then chronological order with TBD times last. Apply the preference to saved snapshots without changing contents, source, coverage flags, or freshness. Preserve other sports’ ordering and existing availability caveats; this preference does not determine League Pass eligibility.
- Cover primary and ESPN fallback listings, mixed national/League Pass broadcasts, radio and regional exclusions, NBA TV, Nuggets in both groups, TBD times, and saved snapshot preservation. Run the Windows fixture runner and `scripts/package-windows.ps1`; use `Tipoff.Check` for a live NBA ordering check and record actual results in validation notes.

The Windows app also registers the packaged executable under the current user's Windows Run key after first launch. The startup argument keeps the flyout hidden while leaving the tray controls available; the tray menu records an explicit opt-out and refreshes the executable path when enabled.

## First version

Built for personal use in the United States and shared publicly as-is; initially NBA only. Match Bug and Worklog’s native menu bar design. Time follows the Mac (Mountain Time for the initial user). Prioritize broadcast information and suppress scores entirely.

Implemented: daily navigation, local times, primary NBA.com game-card data, ESPN fallback, all supplied US TV/streaming broadcaster groups, compact three-column game rows with stacked teams (radio hidden), manual/automatic refresh, bounded offline cache, source/freshness visibility, launch at login, basketball app/menu bar icons, packaging, and automated validation.

Previous/next day arrows have 28×28-point rectangular click targets, including the empty space around each unchanged chevron.

## Personal Nuggets addition

Implemented: On macOS and Windows, NBA games with source-listed national TV/streaming broadcasters appear before League Pass and regional-only listings. Nuggets lead within each group, with the same mint outline and team label used for Broncos games within NFL. The ordering also applies to saved schedules without changing their data or freshness; remaining games within each group stay in time order. NBA TV alone does not receive national priority. Missing listings stay in the later group without implying League Pass eligibility. Altitude’s official Nuggets table supplements matching games, including Altitude / Altitude 2 / Altitude+, channel 9/20 variants, all other source-listed networks, pregame/postgame times, and regional footnotes. Details are available without changing the three-column layout. Date/opponent/home-away/tipoff agreement is required; source failures use clearly labeled saved data when available. Radio remains hidden. No location or subscription eligibility is inferred.

## NFL with Broncos emphasis — version 0.3.2

Implemented: NBA / NFL selector and daily NFL listings with Denver first. Broncos cards have a mint outline within the NFL schedule, just as Nuggets games belong within NBA. Teams are not separate sport sections. The separate Broncos tab and five-week team schedule from 0.3.0 have been removed. The menu bar and header icons follow the sport. NFL’s Sunday shortcut jumps to the upcoming Sunday using the Mac’s calendar and is hidden on Sunday views. NBA keeps Today. The existing 360-point width and NBA / Altitude behavior remain.

ESPN supplies NFL daily schedules, including source-listed networks only. Unknown kickoff times remain TBD. NFL visibly identifies ESPN as its source and has no independent fallback source, but does not repeat a routine coverage disclaimer. Cache keys and stale-response guards separate NBA and NFL; existing daily cache files remain readable. Old Broncos-window caches are not used as daily NFL data. No scores or live telemetry enter models or caches.

## WNBA, then NHL, then MLB — version 0.4.0

Implemented in that order: WNBA daily listings from ESPN, NHL daily listings from NHL.com, and MLB daily listings from MLB.com, with ESPN fallback for NHL/MLB. The selector is NBA / NFL / WNBA / NHL / MLB, still within 360 points. Each sport keeps its own source/freshness label and cache key. WNBA/NHL/MLB use Today; NFL keeps Sunday. Nuggets/Broncos highlighting stays inside NBA/NFL.

WNBA uses source-listed national/local/streaming names without inferring League Pass access. NHL filters country-tagged TV listings to US entries and warns that streaming options may be omitted. MLB retains source-provided regional/national broadcaster names, including streaming brands in its TV list, and labels doubleheader games. Unknown times stay TBD; postponed/cancelled/suspended notices do not expose game telemetry. Both league decoders validate source-day/count metadata and reject malformed formats, so a failed primary falls back to ESPN and a total failure retains saved data and its original freshness.

[Source research](SOURCE-RESEARCH.md) records the earlier investigation and remaining gaps. An Avalanche/Altitude supplement remains a possible follow-up; it is not part of this version. This app remains a personal tool shared as-is, with no release cadence or support promise.

## Rockies and Avalanche preference — version 0.4.1

Implemented: Avalanche games lead the NHL list and Rockies games lead MLB, with the same mint outline and uppercase team label used for Nuggets/Broncos. Identity is scoped to each sport, recognizing NHL/COL and MLB's team ID 115 plus ESPN's COL abbreviation. Multiple preferred games retain time order (including doubleheaders); remaining games are chronological. Existing saved snapshots receive the display preference without rewriting schedule fields, source, or freshness. WNBA remains chronological and the sport selector stays unchanged. No broadcaster or network behavior is changed.

## Possible next steps (not commitments)

- Click a broadcaster to open its watch page (explicitly deferred by the user).
- Optional favorite teams and reminders.
- Location/subscription preferences and stronger local-market availability handling.
- Trial a licensed feed (Sportradar is the strongest documented candidate) if website-source reliability or coverage proves insufficient. Validate streaming coverage with actual samples first.
- Global broadcaster regions, then additional professional sports and college sports.
- Notarization, Intel validation, or an update workflow if someone wants to add them.
- Bring the remaining Windows pieces to parity: dark theme, Arm64, installer/signing, and a published artifact if desired.

The repository includes a basic downloadable Apple Silicon build. This is a shared personal project, not a supported product roadmap.

Do not add scores, standings, or live game telemetry to this product without an explicit change in direction.
