# Candidate sources: WNBA, MLB, NHL

Investigated October 20, 2026 for Tipoff. This records the investigation before integration. Version 0.4.0 now implements WNBA (ESPN), NHL (league feed with ESPN fallback), and MLB (league feed with ESPN fallback), in that order. The Avalanche/Altitude supplement is still only a candidate; this document is not a product commitment. Findings below come from direct HTTP/JSON probes and first-party website inspection; sample coverage is not a completeness guarantee.

## Recommended starting points

| Sport | Proposed primary | Fallback / supplement | Finding |
| --- | --- | --- | --- |
| WNBA | ESPN website schedule JSON | First-party schedule feed still needs verification; official WNBA/team broadcast pages provide cross-checks | Closest fit to the existing ESPN decoder; sampled national, local, and explicitly named streaming networks |
| MLB | MLB schedule JSON with `hydrate=broadcasts` | ESPN website schedule JSON | First-party feed includes home/away/national broadcast metadata; both feeds returned 14 games on the sampled regular-season day |
| NHL | NHL website schedule JSON | ESPN fallback; Altitude's Avalanche table is a promising optional supplement | First-party feed has country/market-tagged TV networks; ESPN includes additional streaming listings, so neither should be assumed complete |

These public website dependencies were accessed without credentials, but are not treated as stable, supported integration contracts. No commercial feed or API-key service was evaluated in this pass. Public accessibility does not itself establish redistribution rights. Continue the existing personal-tool/as-is framing.

## WNBA

Verified ESPN endpoint: `https://site.api.espn.com/apis/site/v2/sports/basketball/wnba/scoreboard?dates=YYYYMMDD&limit=100`.

- May 8, June 21, and July 2, 2026: HTTP 200, three events each, league identity `WNBA`.
- June 21 examples included CBS and Paramount+ together for one matchup, and NBA TV plus local networks for another. July 2 examples included Prime Video, KFAA-TV, MNMT, Atlanta News First, and Victory+ ATL across sampled matchups. These are source labels, not inferred platform mappings.
- July 1 and October 20 returned valid empty event arrays. Checking several in-season dates was necessary; an empty sample alone would not establish that a feed is unusable.
- The [WNBA schedule page](https://www.wnba.com/schedule) returned HTML with `__NEXT_DATA__`, but the inspected page props held filters/configuration rather than NBA-style game cards. Tipoff's NBA page decoder cannot be reused directly.
- Candidate CDN URLs `https://cdn.wnba.com/static/json/staticData/scheduleLeagueV2_1.json` and `https://cdn.wnba.com/static/json/staticData/scheduleLeagueV2.json` returned HTML, not usable schedule JSON. The tested NBA CDN WNBA-suffix candidate returned HTTP 403. These results reject those tested URLs, not every possible first-party feed. No first-party WNBA JSON feed was verified in this pass.

Cross-check sources: [official 2026 national broadcast announcement](https://www.wnba.com/news/broadcast-schedule-release-2026), [WNBA League Pass FAQ](https://www.wnba.com/webview/leaguepass/faq), and individual team broadcast pages. They help assess omissions; do not turn season-wide partner announcements into game-specific availability or default missing listings to League Pass.

## MLB

Verified primary endpoint: `https://statsapi.mlb.com/api/v1/schedule?sportId=1&date=YYYY-MM-DD&hydrate=broadcasts`.

- July 1, 2026: HTTP 200, 14 games, all with broadcast entries. Sample fields include `gamePk`, `gameDate`, `officialDate`, `gameNumber`, `doubleHeader`, and `broadcasts` with `name`, `type`, `homeAway`, `isNational`, and language.
- A Rockies-specific query adding `teamId=115` returned one July 1 game with Rockies.TV and the opponent's Marlins.TV listing, directly supplied by MLB.
- October 23 returned one postseason game with source-listed FOX / FOX ONE and Fox Deportes / FOX ONE. October 20 and December 25 returned empty days with `totalGames: 0` and `totalItems: 0`. A zero-game postseason date is not a decoder failure.
- ESPN comparison endpoint `https://site.api.espn.com/apis/site/v2/sports/baseball/mlb/scoreboard?dates=20260701&limit=100` returned 14 events, all with video listings. Examples included MLB.TV and regional networks. This establishes a viable fallback candidate, not exact broadcaster parity.
- MLB broadcast metadata also contains availability/authentication/media-state fields. Do not interpret `availableForStreaming`, `freeGame`, archive state, or a territory label as eligibility for this Mac/user. Decode only the fields needed for schedule, source-listed broadcasters, and relevant publisher notes; never persist the raw response.

Implementation must preserve separate IDs for doubleheaders, handle postponed/rescheduled/suspended dates without duplicate or missing listings, and distinguish a scheduled start from an unassigned time. `gamePk` is preferable to matchup/date as identity. Broadcaster `type: TV` can include a streaming brand such as Rockies.TV; do not classify it as radio or discard it based on its name. Deduplicate repeated national networks without erasing language/market distinctions that matter to the user.

Reference pages: [MLB schedule](https://www.mlb.com/schedule), [MLB.TV availability](https://support.mlb.com/s/article/MLB-TV-Game-Availability?language=en_US), and [Rockies viewing packages](https://www.mlb.com/live-stream-games/subscribe/rockies). None establishes that a particular user's general MLB.TV subscription includes a listed game.

## NHL

Verified primary endpoint: `https://api-web.nhle.com/v1/schedule/YYYY-MM-DD`.

- October 20, 2026: HTTP 200; `gameWeek` covered October 20–26, with 47 games across seven days. October 20 contained 11 games. Every game in that returned week had `tvBroadcasts`; a listing can still lack some streaming/local options.
- Useful fields include game `id`, `startTimeUTC`, `gameScheduleState`, teams, and `tvBroadcasts` with `network`, `countryCode`, and `market` (home/away/national context). Filter country explicitly for Tipoff's US scope; Canadian networks must not be represented as US availability.
- `https://api-web.nhle.com/v1/club-schedule-season/COL/20262027` returned 88 Avalanche preseason/regular-season entries, 86 with TV listings. Missing listings must remain unknown rather than receive a default network.
- ESPN endpoint `https://site.api.espn.com/apis/site/v2/sports/hockey/nhl/scoreboard?dates=20261020&limit=100` returned 11 events, all with video listings. For Colorado at New Jersey, the NHL feed supplied ALT, KTVD, MSG and MSG 2; ESPN supplied Altitude Sports, KTVD-TV (My20), MSG, MSG2 and ESPN+. Do not conclude that ESPN+'s label overrides local restrictions, or that the first-party TV list proves no streaming option exists.
- The NHL response is a multi-day window, not the selected day's array. Filter by local start time and inspect adjacent source windows when needed at time-zone boundaries. Preserve unknown times and calendar-day navigation; never decode scores, periods, or game clocks into the model.

### Avalanche / Altitude candidate

The correct table URL verified in this pass is [Altitude's Avalanche broadcast schedule](https://www.altitudeplus.com/avs-broadcasts). The guessed `/avalanche-broadcasts` path returned a generic page without a schedule table and should not be used.

The correct response contains a table with Date, Matchup, Home/Away, Pregame, Game Start, Postgame, and Networks fields, embedded in escaped page content. This is similar to the current Nuggets supplement, but its decoder/matching behavior has not been implemented or tested. If added, require date/opponent/home-away/start-time agreement, retain regional notes and original saved-data freshness, and leave primary listings usable when the supplement fails. Do not simply apply the Nuggets decoder to an Avalanche page.

The [Avalanche's official viewing guide](https://www.nhl.com/avalanche/fans/how-to-watch) is another publisher-provided cross-check for regional and national broadcasts, including explicitly listed streaming platforms on selected dates.

## Integration checklist from the research

1. Generalize league identity validation and game-ID namespacing. The current ESPN decoder's NFL boolean must not cause WNBA/MLB/NHL events to be saved with NBA or NFL IDs.
2. Capture minimal schedule/broadcast fixtures from the chosen sources, plus legitimate empty days, malformed/schema-change responses, source errors, missing networks, TBD times, doubleheaders/rescheduling, US/Canadian broadcast filtering, and time-zone/DST boundaries. No scores or visitor data in retained fixtures/models/caches.
3. Keep sport/date/time-zone caches isolated and preserve good snapshots on source failures. Validate response day/league/count metadata before accepting an empty result or a truncated schedule.
4. Keep teams inside their sports. Any future Avalanche/Rockies emphasis belongs within NHL/MLB. No favorite or team preference change is made by this research.
5. For actual integration, run `scripts/test.sh`, `scripts/package-app.sh`, live `TipoffCheck` per new sport, and native 360-point renders. The original research pass changed documentation only; see VALIDATION.md for subsequent executed integration tests and live checks.

The original recommendation was NHL, WNBA, then MLB. Implementation subsequently proceeded WNBA, NHL, then MLB; this is not a release-cadence commitment.
