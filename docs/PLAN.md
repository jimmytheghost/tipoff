# Product plan

## First version

Built for personal use in the United States and shared publicly as-is; NBA only. Match Bug and Worklog’s native menu bar design. Time follows the Mac (Mountain Time for the initial user). Prioritize broadcast information and suppress scores entirely.

Implemented: daily navigation, local times, primary NBA.com game-card data, ESPN fallback, all supplied US TV/streaming broadcaster groups, compact three-column game rows with stacked teams (radio hidden), manual/automatic refresh, bounded offline cache, source/freshness visibility, launch at login, basketball app/menu bar icons, packaging, and automated validation.

## Personal Nuggets addition

Implemented: Altitude’s official Nuggets table supplements matching games, including Altitude / Altitude 2 / Altitude+, channel 9/20 variants, all other source-listed networks, pregame/postgame times, and regional footnotes. Details are available without changing the three-column layout. Date/opponent/home-away/tipoff agreement is required; source failures use clearly labeled saved data when available. Radio remains hidden. No location or subscription eligibility is inferred.

## Possible next steps (not commitments)

- Click a broadcaster to open its watch page (explicitly deferred by the user).
- Optional favorite teams and reminders.
- Location/subscription preferences and stronger local-market availability handling.
- Trial a licensed feed (Sportradar is the strongest documented candidate) if website-source reliability or coverage proves insufficient. Validate streaming coverage with actual samples first.
- Global broadcaster regions, then other professional sports and college sports.
- Notarization, Intel validation, or an update workflow if someone wants to add them.

The repository includes a basic downloadable Apple Silicon build. This is a shared personal project, not a supported product roadmap.

Do not add scores, standings, or live game telemetry to this product without an explicit change in direction.
