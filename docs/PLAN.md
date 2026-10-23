# Product plan

The [current app screenshot](current-preview.png), captured October 22, 2026, shows the five-sport selector and Nuggets broadcast details in version 0.4.1. The README uses this capture; older sport-specific previews remain available.

The existing app icon is exported to `img/Tipoff.png` as a reusable 2048×2048 PNG with transparency.

## Windows system-tray first pass — October 2026

Implemented in `Windows/` as a package-free C# / WPF companion, without changing the SwiftUI app. The Windows tray flyout keeps the 360-unit width, mint accent, rounded cards, five sport guides, local calendar-day navigation, NFL Sunday shortcut, Denver/Colorado display ordering, source/freshness labels, coverage warnings, and isolated saved snapshots. It ports the NBA.com / ESPN / NHL.com / MLB.com source hierarchy and projects only schedule and broadcaster fields into its model. Fixture tests explicitly verify that scores, clocks, periods, and standings do not enter serialized games.

The first pass opens its flyout on launch, toggles from the notification-area icon, and has Open / Refresh / Quit tray actions. It includes a Windows `Tipoff.Check` and a PowerShell packaging script. The output is currently a framework-dependent x64 source build requiring the .NET 9 Desktop Runtime; no installer or published Windows release is claimed. The Windows guide now also carries the Nuggets Altitude supplement, strict schedule agreement, separate saved-data fallback, and expandable details for source networks, show times, regional notes, and freshness.

Still deferred from the first Windows pass: launch at login, system dark-theme adaptation, Arm64 packaging, installer/signing, and automatic updates.

## First version

Built for personal use in the United States and shared publicly as-is; initially NBA only. Match Bug and Worklog’s native menu bar design. Time follows the Mac (Mountain Time for the initial user). Prioritize broadcast information and suppress scores entirely.

Implemented: daily navigation, local times, primary NBA.com game-card data, ESPN fallback, all supplied US TV/streaming broadcaster groups, compact three-column game rows with stacked teams (radio hidden), manual/automatic refresh, bounded offline cache, source/freshness visibility, launch at login, basketball app/menu bar icons, packaging, and automated validation.

Previous/next day arrows have 28×28-point rectangular click targets, including the empty space around each unchanged chevron.

## Personal Nuggets addition

Implemented: Nuggets games appear first within NBA, with the same mint outline and team label used for Broncos games within NFL. The ordering also applies to saved schedules without changing their freshness; other NBA games remain in time order. Altitude’s official Nuggets table supplements matching games, including Altitude / Altitude 2 / Altitude+, channel 9/20 variants, all other source-listed networks, pregame/postgame times, and regional footnotes. Details are available without changing the three-column layout. Date/opponent/home-away/tipoff agreement is required; source failures use clearly labeled saved data when available. Radio remains hidden. No location or subscription eligibility is inferred.

## NFL with Broncos emphasis — version 0.3.2

Implemented: NBA / NFL selector and daily NFL listings with Denver first. Broncos cards have a mint outline within the NFL schedule, just as Nuggets games belong within NBA. Teams are not separate sport sections. The separate Broncos tab and five-week team schedule from 0.3.0 have been removed. The menu bar and header icons follow the sport. NFL’s Sunday shortcut jumps to the upcoming Sunday using the Mac’s calendar and is hidden on Sunday views. NBA keeps Today. The existing 360-point width and NBA / Altitude behavior remain.

ESPN supplies NFL daily schedules, including source-listed networks only. Unknown kickoff times remain TBD. NFL has a visible limited-coverage notice and no independent fallback source. Cache keys and stale-response guards separate NBA and NFL; existing daily cache files remain readable. Old Broncos-window caches are not used as daily NFL data. No scores or live telemetry enter models or caches.

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
- Bring the remaining Windows preview pieces to parity: launch at login, dark theme, Arm64, installer/signing, and a published artifact if desired.

The repository includes a basic downloadable Apple Silicon build. This is a shared personal project, not a supported product roadmap.

Do not add scores, standings, or live game telemetry to this product without an explicit change in direction.
