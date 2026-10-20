# Data sources and limitations

The primary source is the structured `__NEXT_DATA__` embedded in `https://www.nba.com/games?date=YYYY-MM-DD`. This is the NBA’s own game-card data, including broadcast arrays. The separate NBA CDN schedule endpoint returned HTTP 403 during development; Tipoff does not depend on that endpoint.

ESPN’s public website schedule endpoint is the fallback. Fallback mode is visibly labeled because local and streaming listings may be incomplete. Tipoff does not infer Peacock from NBC, infer League Pass eligibility, or guess local networks. Even NBA.com sometimes omits local TV information. A listed service is not a determination of eligibility or blackout status.

These website endpoints are undocumented dependencies, with no availability guarantee. A page/schema change can require a decoder update. On failure Tipoff retains its last successful cache rather than displaying a false empty schedule. `Checked` means retrieved by Tipoff, not a claim that the upstream broadcaster independently reconfirmed it.

Source dates use Eastern time. Tipoff fetches every source date intersecting the user’s local day, filters by local start time, and removes duplicates. An unknown tipoff time stays on the source’s named schedule date and displays `Time TBD`.

Schedule caches live in `~/Library/Application Support/Tipoff/Schedules/` and contain only the app’s schedule/broadcast model, never scores. At most 45 snapshots are retained. No analytics, cloud account, or paid service is used.

## Nuggets / Altitude supplement

For this personal version, Nuggets games also consult [Altitude’s Nuggets broadcast schedule](https://www.altitudeplus.com/nuggets-broadcasts). Listed channels appear first in the existing three-column row. `Details` opens pregame/game/postgame times in your Mac’s time zone, the source’s exact network labels, the last Altitude check time, and the source link. `Details*` indicates regional notes: the source distinguishes Denver-DMA exclusivity from outer-market coverage; all listed channels should not be assumed available in the same location.

[Row preview](altitude-preview.png) · [Broadcast details preview](altitude-details.png).

The supplement matches the Mountain calendar date, opponent, and home/away designation. Its published tipoff must agree with the main schedule within one minute. Changed or mismatched games keep their primary listings and display a warning. National-only games do not acquire invented Altitude coverage. Other teams are unaffected.

Altitude is fetched on refresh only when a Nuggets game is on the selected day. Parsed schedule/broadcast fields are cached separately at `~/Library/Application Support/Tipoff/Altitude.json`; page configuration and visitor metadata are never stored. On a failed Altitude request, a saved supplement can still be used with an explicit warning and its original check timestamp. Primary NBA/ESPN listings remain usable when Altitude is unavailable. No-match or format changes are reported rather than silently assumed to mean no broadcast.

The publisher’s clocks are interpreted as America/Denver, with daylight saving time; the agreement check against the main feed prevents applying a conflicting tipoff. Pregame/postgame times come directly from the publisher, not from calculated offsets. This is another undocumented page dependency, with no guarantee of completeness or unchanged rights.

