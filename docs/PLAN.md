# Product plan

## First version

Built for personal use in the United States and shared publicly as-is; initially NBA only. Match Bug and Worklog’s native menu bar design. Time follows the Mac (Mountain Time for the initial user). Prioritize broadcast information and suppress scores entirely.

Implemented: daily navigation, local times, primary NBA.com game-card data, ESPN fallback, all supplied US TV/streaming broadcaster groups, compact three-column game rows with stacked teams (radio hidden), manual/automatic refresh, bounded offline cache, source/freshness visibility, launch at login, basketball app/menu bar icons, packaging, and automated validation.

## Personal Nuggets addition

Implemented: Altitude’s official Nuggets table supplements matching games, including Altitude / Altitude 2 / Altitude+, channel 9/20 variants, all other source-listed networks, pregame/postgame times, and regional footnotes. Details are available without changing the three-column layout. Date/opponent/home-away/tipoff agreement is required; source failures use clearly labeled saved data when available. Radio remains hidden. No location or subscription eligibility is inferred.

## NFL / Broncos — version 0.3.0

Implemented: NBA / NFL / Broncos selector, daily NFL listings with Denver first, and a dedicated Broncos view spanning 35 local calendar days from the selected date. Denver cards have a mint outline; Broncos rows include their game date. The menu bar and header icons follow the sport. The existing 360-point width and NBA / Altitude behavior remain.

ESPN supplies NFL daily and Broncos team schedules, including source-listed networks only. The team view checks preseason, regular season, and postseason for season years touching its window. Unknown kickoff times remain TBD; unassigned future games can be absent. NFL has a visible limited-coverage notice and no independent fallback source. Cache keys and stale-response guards separate all three guides; existing NBA cache files remain readable. No scores or live telemetry enter models or caches.

## Possible next steps (not commitments)

- Click a broadcaster to open its watch page (explicitly deferred by the user).
- Optional favorite teams and reminders.
- Location/subscription preferences and stronger local-market availability handling.
- Trial a licensed feed (Sportradar is the strongest documented candidate) if website-source reliability or coverage proves insufficient. Validate streaming coverage with actual samples first.
- Global broadcaster regions, then additional professional sports and college sports.
- Notarization, Intel validation, or an update workflow if someone wants to add them.

The repository includes a basic downloadable Apple Silicon build. This is a shared personal project, not a supported product roadmap.

Do not add scores, standings, or live game telemetry to this product without an explicit change in direction.
