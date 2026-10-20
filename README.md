# Tipoff

A native macOS menu bar app that answers: who’s playing, when, and where can I watch?

Tipoff starts with the NBA and matches Bug / Worklog: a 360-point SwiftUI popover, mint accent, system typography, and rounded cards. Requires macOS 15 or newer.

## First version

- Basketball menu bar icon; no Dock window.
- Today’s games, with previous/next day navigation.
- Compact three-column game rows: stacked away/home teams (`@`), local tipoff time, and TV/streaming listings, sorted by scheduled tipoff.
- Times follow the Mac’s time zone, including daylight saving changes. Tested for America/Denver.
- National, local, streaming, and subscription broadcasters when listed by the source. Radio is hidden.
- No scores, standings, game clocks, or live game status. Postponements, cancellations, and delays can appear because they affect the schedule.
- Refresh on opening, after wake, on date/time-zone changes, and every five minutes while running.
- Cached schedules with visible freshness and refresh-failure labels.
- Launch at login setting, off until enabled.

## Build and run

```sh
swift build
scripts/test.sh
scripts/package-app.sh
mkdir -p ~/Applications
ditto dist/Tipoff.app ~/Applications/Tipoff.app
open ~/Applications/Tipoff.app
```

Use the basketball icon in the macOS menu bar to open Tipoff. No account or API key is required. Packaging uses ad-hoc signing unless `TIPOFF_SIGNING_IDENTITY` names an available certificate.

## Data and accuracy

The primary source is the structured `__NEXT_DATA__` embedded in `https://www.nba.com/games?date=YYYY-MM-DD`. This is the NBA’s own game-card data, including broadcast arrays. The separate NBA CDN schedule endpoint returned HTTP 403 during development; Tipoff does not depend on that endpoint.

ESPN’s public website schedule endpoint is the fallback. Fallback mode is visibly labeled because local and streaming listings may be incomplete. Tipoff does not infer Peacock from NBC, infer League Pass eligibility, or guess local networks. Even NBA.com sometimes omits local TV information. A listed service is not a determination of eligibility or blackout status.

These website endpoints are undocumented dependencies, with no availability guarantee. A page/schema change can require a decoder update. On failure Tipoff retains its last successful cache rather than displaying a false empty schedule. `Checked` means retrieved by Tipoff, not a claim that the upstream broadcaster independently reconfirmed it.

Source dates use Eastern time. Tipoff fetches every source date intersecting the user’s local day, filters by local start time, and removes duplicates. An unknown tipoff time stays on the source’s named schedule date and displays `Time TBD`.

Schedule caches live in `~/Library/Application Support/Tipoff/Schedules/` and contain only the app’s schedule/broadcast model, never scores. At most 45 snapshots are retained. No analytics, cloud account, or paid service is used.

## Development

`Sources/TipoffCore/` contains models, source decoders, the network provider, cache, store, and popover. `Sources/Tipoff/` is the menu bar entry point. `Sources/TipoffCheck/` is a development-only live-source check / renderer; it is not packaged in the app.

```sh
swift run TipoffCheck 2026-10-20
.build/debug/TipoffCheck --render /tmp/tipoff-preview.png
```

The live check prints scheduling/broadcast information and writes `/tmp/tipoff-preview.png.json`. The renderer uses that snapshot, without network requests. Add `--light` before the image path for a light-mode render.

See [docs/PLAN.md](docs/PLAN.md) for future scope and [docs/VALIDATION.md](docs/VALIDATION.md) for executed checks and remaining manual checks.

## Repository

Private GitHub repository: [jimmytheghost/tipoff](https://github.com/jimmytheghost/tipoff).

`main` tracks `origin/main`. Build outputs and local schedule caches are excluded from version control. Contributor instructions are in [AGENTS.md](AGENTS.md).
