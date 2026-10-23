# Data sources and limitations

The primary source is the structured `__NEXT_DATA__` embedded in `https://www.nba.com/games?date=YYYY-MM-DD`. This is the NBA’s own game-card data, including broadcast arrays. The separate NBA CDN schedule endpoint returned HTTP 403 during development; Tipoff does not depend on that endpoint.

ESPN’s public website schedule endpoint is the fallback. Fallback mode is visibly labeled because local and streaming listings may be incomplete. Tipoff does not infer Peacock from NBC, infer League Pass eligibility, or guess local networks. Even NBA.com sometimes omits local TV information. A listed service is not a determination of eligibility or blackout status.

These website endpoints are undocumented dependencies, with no availability guarantee. A page/schema change can require a decoder update. On failure Tipoff retains its last successful cache rather than displaying a false empty schedule. `Checked` means retrieved by Tipoff, not a claim that the upstream broadcaster independently reconfirmed it.

Source dates use Eastern time. Tipoff fetches every source date intersecting the user’s local day, filters by local start time, and removes duplicates. An unknown tipoff time stays on the source’s named schedule date and displays `Time TBD`.

Schedule caches live in `~/Library/Application Support/Tipoff/Schedules/` on macOS and `%LOCALAPPDATA%\Tipoff\Schedules\Windows\` in the Windows app. They contain only the app’s schedule/broadcast model, never scores. Each implementation retains at most 45 snapshots. No analytics, cloud account, or paid service is used.

## Nuggets / Altitude supplement

For this personal version, Nuggets games also consult [Altitude’s Nuggets broadcast schedule](https://www.altitudeplus.com/nuggets-broadcasts). Listed channels appear first in the existing three-column row. `Details` opens pregame/game/postgame times in the computer’s time zone, the source’s exact network labels, and the Altitude freshness. `Details*` indicates regional notes: the source distinguishes Denver-DMA exclusivity from outer-market coverage; all listed channels should not be assumed available in the same location. Both the macOS and Windows versions apply these rules.

[Row preview](altitude-preview.png) · [Broadcast details preview](altitude-details.png).

The supplement matches the Mountain calendar date, opponent, and home/away designation. Its published tipoff must agree with the main schedule within one minute. Changed or mismatched games keep their primary listings and display a warning. National-only games do not acquire invented Altitude coverage. Other teams are unaffected.

Altitude is fetched on refresh only when a Nuggets game is on the selected day. Parsed schedule/broadcast fields are cached separately at `~/Library/Application Support/Tipoff/Altitude.json` on macOS and `%LOCALAPPDATA%\Tipoff\Altitude.Windows.json` on Windows; page configuration and visitor metadata are never stored. On a failed Altitude request, a saved supplement can still be used with an explicit warning and its original check timestamp. Primary NBA/ESPN listings remain usable when Altitude is unavailable. No-match or format changes are reported rather than silently assumed to mean no broadcast.

The publisher’s clocks are interpreted as America/Denver, with daylight saving time; the agreement check against the main feed prevents applying a conflicting tipoff. Pregame/postgame times come directly from the publisher, not from calculated offsets. This is another undocumented page dependency, with no guarantee of completeness or unchanged rights.

## NFL with Denver Broncos emphasis — version 0.3.1

NFL uses ESPN’s public website JSON at `site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard?dates=YYYYMMDD&limit=100`. Tipoff requests the Eastern dates intersecting the selected local day, rejects wrong-date responses, filters to the local day, deduplicates events, and puts Denver first. The endpoint name does not change Tipoff’s scope: only schedule and broadcaster fields are decoded into the app’s model.

The top-level guides are NBA, NFL, WNBA, NHL, and MLB. Denver matchups are highlighted within NFL. Version 0.3.1 removed the separate Broncos window and its team-schedule requests; every visible game belongs to the selected local day.

ESPN’s daily geo/legacy broadcast lists are supported. Only source-listed US/unspecified-region broadcasters are used. Radio stays hidden in the UI. CBS, Fox, or another listed network does not establish which local affiliate carries a game, reception in Denver, streaming access, or subscription eligibility. No Altitude supplement is applied to NFL. Flex scheduling may change kickoffs and networks; refresh before watching.

NFL always shows a limited-coverage notice. ESPN is its only source: network, HTTP, and detected schema errors retain the last successful snapshot for that guide, date, and time zone, with its original timestamp. There is no silent fallback to NBA data. NFL cache filenames use an `nfl-` prefix; NBA filenames and older daily snapshots remain compatible. Older `broncos-` window files are ignored, never reinterpreted as daily NFL listings. The shared 45-snapshot limit still applies. Source pages and raw API responses are never saved as app caches. Sanitized schedule-only fixtures cover daily NFL listings and TBD kickoffs.

## WNBA / NHL / MLB — version 0.4.0

WNBA uses `https://site.api.espn.com/apis/site/v2/sports/basketball/wnba/scoreboard?dates=YYYYMMDD&limit=100`. It is ESPN-only, with a visible limited-coverage warning, just like NFL. The ESPN decoder now validates the requested league identity and namespaces non-NBA game IDs by sport; NBA and NFL IDs/caches remain compatible. Missing networks remain unlisted. An empty WNBA day is shown as an empty schedule, not proof that the season has ended. Streaming partners and League Pass eligibility are never inferred from a TV network name.

NHL uses `https://api-web.nhle.com/v1/schedule/YYYY-MM-DD`. This returns a multi-day `gameWeek`; Tipoff validates the full returned count and extracts only the requested source day before filtering to the computer's local calendar day. It reads team names, start time, schedule-change flags and `tvBroadcasts` only. US-tagged broadcaster names and home/away/national context are preserved; Canadian entries are excluded for this guide. The source's TV list may omit streaming options, so the primary feed also shows a coverage warning. It can itself include explicitly named streaming brands. The Avalanche/Altitude table found during research is not integrated.

MLB uses `https://statsapi.mlb.com/api/v1/schedule?sportId=1&date=YYYY-MM-DD&hydrate=broadcasts`. It validates response dates and total-game counts. Each `gamePk` remains a separate event, including doubleheaders; source game numbers appear as Game 1 / Game 2 notices. `gameDate` determines the selected-day start; `status.startTimeTBD` keeps unknown times TBD. Postponed/cancelled/delayed/suspended notices are whitelisted; other game status, scores, records, inning data, media state, availability/authentication flags, and raw responses do not enter the model/cache. Postponed rows retain their original source-day listing; a `rescheduleDate` is not used to move a row into a different selected day. Rescheduled listings are shown when supplied for their new date. Missing or unusual suspension/resumption listings can still require checking the publisher.

Only MLB broadcast entries explicitly classified TV are shown; this includes publisher-named streaming brands such as Rockies.TV. Home/away/national metadata is retained, with repeated entries deduplicated within a category. A publisher listing may include the opponent's feed and does not establish US reception, local affiliate coverage, subscription access, or blackout eligibility. AM/FM entries are omitted by this decoder; unknown broadcaster types trigger a schema failure and fallback rather than silently erasing listings. Long publisher/sponsor names wrap in the existing broadcaster column.

NHL/MLB primary errors (HTTP, network, or detected schema changes) retry all intersecting dates through ESPN's `hockey/nhl` or `baseball/mlb` endpoint. The snapshot clearly says fallback and warns about coverage. Primary and fallback records are not mixed. If both fail, the store keeps the saved sport/date/time-zone snapshot with its original retrieval time. WNBA/NHL/MLB cache files use `wnba-`, `nhl-`, and `mlb-` prefixes; the existing shared 45-snapshot cap remains. Local-day filtering, deduplication, DST behavior and no-score persistence apply to every sport.

## Colorado team display preference — version 0.4.1

Avalanche games (`nhl-` / `nhl-espn-` IDs with team code COL) and Rockies games (`mlb-` IDs with MLB team ID 115, or `mlb-espn-` with COL) are displayed first in their respective sport, with a mint outline and team label. The preference is calculated at display time, including for older cached snapshots; cached game arrays, source attribution, broadcasters, coverage flags, and original retrieval timestamps are preserved. Preferred games remain chronological, as do all other games after them. This adds no new source or viewing-eligibility inference. NHL's existing coverage warning remains, and the Avalanche/Altitude supplement is still not integrated.
