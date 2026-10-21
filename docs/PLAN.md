# Product plan

## First version

Built for personal use in the United States and shared publicly as-is; initially NBA only. Match Bug and Worklog’s native menu bar design. Time follows the Mac (Mountain Time for the initial user). Prioritize broadcast information and suppress scores entirely.

Implemented: daily navigation, local times, primary NBA.com game-card data, ESPN fallback, all supplied US TV/streaming broadcaster groups, compact three-column game rows with stacked teams (radio hidden), manual/automatic refresh, bounded offline cache, source/freshness visibility, launch at login, basketball app/menu bar icons, packaging, and automated validation.

## Personal Nuggets addition

Implemented: Altitude’s official Nuggets table supplements matching games, including Altitude / Altitude 2 / Altitude+, channel 9/20 variants, all other source-listed networks, pregame/postgame times, and regional footnotes. Details are available without changing the three-column layout. Date/opponent/home-away/tipoff agreement is required; source failures use clearly labeled saved data when available. Radio remains hidden. No location or subscription eligibility is inferred.

## NFL with Broncos emphasis — version 0.3.2

Implemented: NBA / NFL selector and daily NFL listings with Denver first. Broncos cards have a mint outline within the NFL schedule, just as Nuggets games belong within NBA. Teams are not separate sport sections. The separate Broncos tab and five-week team schedule from 0.3.0 have been removed. The menu bar and header icons follow the sport. NFL’s Sunday shortcut jumps to the upcoming Sunday using the Mac’s calendar and is hidden on Sunday views. NBA keeps Today. The existing 360-point width and NBA / Altitude behavior remain.

ESPN supplies NFL daily schedules, including source-listed networks only. Unknown kickoff times remain TBD. NFL has a visible limited-coverage notice and no independent fallback source. Cache keys and stale-response guards separate NBA and NFL; existing daily cache files remain readable. Old Broncos-window caches are not used as daily NFL data. No scores or live telemetry enter models or caches.

## Additional-sport source research

[WNBA / MLB / NHL research](SOURCE-RESEARCH.md) records direct endpoint probes and broadcaster coverage observations. Proposed starting points are ESPN for WNBA, MLB's schedule feed with broadcast hydration for baseball, and NHL's schedule feed with ESPN fallback and a possible Avalanche/Altitude supplement for hockey. These sports are not implemented. Keep teams inside their respective sport, with score-free caches and source-listed broadcasters only.

## Possible next steps (not commitments)

- Click a broadcaster to open its watch page (explicitly deferred by the user).
- Optional favorite teams and reminders.
- Location/subscription preferences and stronger local-market availability handling.
- Trial a licensed feed (Sportradar is the strongest documented candidate) if website-source reliability or coverage proves insufficient. Validate streaming coverage with actual samples first.
- Global broadcaster regions, then additional professional sports and college sports.
- Notarization, Intel validation, or an update workflow if someone wants to add them.

The repository includes a basic downloadable Apple Silicon build. This is a shared personal project, not a supported product roadmap.

Do not add scores, standings, or live game telemetry to this product without an explicit change in direction.
