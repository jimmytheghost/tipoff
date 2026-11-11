# Tipoff website handoff

The local Tomorrow typography preview is on `codex/tipoff-tomorrow-preview`. Run `scripts/preview-web.sh 8766` and open `http://127.0.0.1:8766/tipoff`. The page uses Tomorrow at 400, 500, 600, and 700, with the original Barlow Condensed ExtraBold Italic wordmark. Team names use weight 500 at 14 px on phones and 15 px on larger screens. Following card headings display team names in uppercase. The browser serves the licensed font files from `web/fonts/`. To publish this preview later, include those files under `assets/fonts/tipoff/` before publishing the versioned stylesheet and guide HTML.

## Frontend release — November 10, 2026

Published `tipoff-web-frontend-20261110-01`, with CSS and JavaScript version `20261110-02`. The release replaces the guide HTML, stylesheet, and JavaScript. Cached HTML can load the updated JavaScript during the transition. The schedule reader and cache were outside the release.

100 JavaScript cases and 16 local route checks passed, along with JavaScript syntax and Git whitespace checks. Nine public release checks and three installed-file hash checks passed. Eight browser and crawler checks covered canonical and shortcut routes and the 1920 × 1080 preview PNG. Messages rendering was not tested. Live checks at 390 and 1280 px confirmed no horizontal overflow, visible mobile broadcaster names, the saved-league notice, and Refresh retaining the selected day. No native tests ran for this presentation release. Screenshots are at `/tmp/tipoff-frontend-live-mobile.jpg` and `/tmp/tipoff-frontend-live-desktop.jpg`. The frozen release includes a guarded rollback.


The browser guide puts broadcaster names below highlighted matchups at widths up to 32 rem. Shorter team names can wrap as needed. Refresh checks the selected day, and a notice above the schedule identifies saved or unavailable leagues. The footer shows original source timestamps.

Updated November 10, 2026. Status: browser guide and expanded portfolio page deployed. The current [Tipoff source](https://github.com/jimmytheghost/tipoff) ships native macOS and Windows apps.

## Portfolio expansion content package — November 7, 2026

Prepared [the portfolio handoff](docs/portfolio/HANDOFF.md), [ready-to-place copy](docs/portfolio/PAGE-COPY.md), and [asset guide](docs/portfolio/ASSETS.md) for a fuller case study following the live tzMiniFigs and Pick a Psych references. Includes 12 page-ready images (six real browser captures, three native macOS renders, a labeled Windows feature diagram, overview composition, and social artwork), three reference captures, a contact sheet, provenance/size/hash manifest, and reproduction scripts. Existing Alec Miller video/poster/credit and supplied motivation are preserved in the instructions and copy. No website implementation or deployment was performed. No Windows desktop was available; an optional real-capture replacement brief is included, and the diagram must remain labeled. Native renders use a live-fetched November 7 NBA.com + Altitude snapshot, seven games. See docs/VALIDATION.md for actual checks.

## Page and routes

- The public viewing guide is at `https://www.jimmyweber.com/tipoff`. `/tip-off` and `/sports` redirect to it and the page metadata uses the canonical URL. Verify slash variants and the final host with the site's routing.
- The existing [Tipoff portfolio entry](https://www.jimmyweber.com/pages/projects/tipoff/) includes a **View the schedule** link. The guide’s header and footer both link directly to the JimmyWeber.com homepage. The local portfolio preview still exercises the inbound schedule link.
- The guide opens to **Following** and **National Broadcasts**, with the full schedule and league filters inside **All Games**, collapsed by default. The landing view omits the visible page title and subtitle. The top heading is Following only when followed games are listed; otherwise it is National Broadcasts when national games are present, without a duplicate heading below. Empty national sections omit the large heading and keep the faint “No national broadcasts listed.” message after successful loading. Date controls sit in the header at 64 rem and wider; on tablet/mobile they span the content width above the section heading. Clicking the displayed date opens the site-themed dark/lime calendar popover, and date changes update both views even when All Games is closed. The time zone and league filters remain inside All Games; filters affect only All Games. Schedule failures remain available in the footer status container. Following currently includes the Nuggets, Broncos, Avalanche, and Rockies; visitor-selectable teams are not implemented. Followed games with national coverage appear once in the highlights and carry a National marker. Highlight groups reuse the approved All Games header component and styles, showing the name on the left and the optional National marker/game count vertically centered on the right, with source/original freshness and fallback/saved labels consolidated in the footer status disclosure. This approved redesign is deployed; the current loading repair is release `tipoff-web-loading-20261106-01`.
- All Games supports **All**, **NBA**, **NFL**, **WNBA**, **NHL**, and **MLB** without changing the selected date. Successful empty leagues go at the bottom with muted, expandable headers and an explicit empty message. National highlights use source-marked national TV or streaming and the NBA feed’s national streaming category. NBA TV, NHL Network, NFL Network / NFL Net / NFLN, league passes, and regional listings do not qualify. Radio listings are hidden throughout the guide. Broadcast details start collapsed for full-schedule games outside both highlight groups. League headers retain game counts; source/freshness appears once per sport in Schedule status. The full schedule uses blue outlines for followed games and lime for other national games.
- Use the visitor’s time zone for the calendar date and game times. Provide the site-themed date/calendar popover, Today, and previous/next day controls. Show full team names when both fit their actual matchup column, shortening city/state prefixes only when needed, alongside scheduled start times and source-listed broadcasters. The frontend preserves multiword team names, leaves unknown names alone, and retains the source names in hover titles and snapshots. Use Tipoff’s own dark scoreboard layout, with start times in lime, matchups that wrap when both team names cannot fit beside the start time, and national broadcaster logos in a consistent-width column before the matchup on the same row. Away-team logos align across national rows regardless of network count. Other broadcast details remain below. National matchup names use an ellipsis when the row cannot fit, with full accessible names and hover titles; inline logo groups remain side by side, shrinking proportionally within their fixed column when needed. Use text labels for the controls and expose the selected state to assistive technology.

## Schedule integration

Run `scripts/preview-web.sh [port]` with the macOS Swift toolchain and Python 3.9 or newer. It builds `TipoffCheck` and listens on loopback (port 8765 by default). The frontend is `web/index.html`, `web/guide.css`, `web/guide.js`, and the supplied artwork `web/brand-mark.png` (deployed to `assets/img/projects/tipoff-header-mark.png`). The preview server also serves `web/portfolio-preview.html` as a stand-in for the portfolio link. The guide uses Roboto for body text and controls, with Barlow Condensed for display headings and times. Team logos prefer ESPN’s published 500-dark artwork across all five sports, using provider-supplied light/outlined variants for the dark surface. Default ESPN artwork is retried on failure. Numeric MLB team IDs map to verified ESPN logo slugs, with the original MLB SVG as a final fallback; unknown numeric IDs keep the MLB SVG. Logo dimensions and source team fields remain intact. Selected network marks use ESPN and Wikimedia-hosted assets, including the [Peacock wordmark](https://commons.wikimedia.org/wiki/File:NBCUniversal_Peacock_Logo_(2026).svg), [FOX wordmark](https://commons.wikimedia.org/wiki/File:FOX_wordmark-black.svg), and [Prime Video mark](https://commons.wikimedia.org/wiki/File:Prime_Video_logo_(2024).svg). Additional marks include [TNT](https://commons.wikimedia.org/wiki/File:TNT_Logo_2016.svg), [HBO Max](https://commons.wikimedia.org/wiki/File:HBO_Max_May_2025_(Horizontal).svg), [truTV](https://commons.wikimedia.org/wiki/File:TruTV_2014.svg), and [Altitude](https://en.wikipedia.org/wiki/File:Altitude_Sports_logo.svg). Both Altitude and the NHL feed’s ALT label use the Altitude mark. Distinct marks now cover [Altitude 2 / ALT2](https://www.tvpassport.com/tv-listings/stations/altitude-2/5864), [Altitude+](https://www.altitudeplus.com/) (the official site’s desktop logo), and [NBA TV](https://en.wikipedia.org/wiki/File:NBA_TV.svg). Altitude 2 uses TV Passport’s transparent PNG and renders white; Altitude+ keeps its official white mark, and NBA TV retains its original colors. Accessible names and text fallback preserve each service identity. These four marks render white for the dark background. Loaded broadcaster logos use proportional boxes based on natural image dimensions, with a shared 0.5 rem gap between networks, regional labels, and team-logo/name pairs. The national network column remains a fixed width for away-logo alignment. Loaded broadcaster logos replace the visible names. The names remain available to assistive technology and display as text until a logo loads or when a logo is unavailable. Regional and radio labels follow the feed categories. The LP badge applies only to a separately listed League Pass entry.

The local `GET /tipoff/schedule?sport=nba&day=YYYY-MM-DD&zone=America%2FDenver` endpoint invokes `TipoffCheck --web <sport> <day> <zone> <cache-directory>`. It returns `{snapshot, saved}` with ISO 8601 dates and a null or absent snapshot when listings are unavailable. It reuses the native source and display logic. The preview cache is under `.build/web-cache`, with a five-minute freshness window and a separate Altitude cache.

Production uses Apache and PHP 8.1. Apache routes the schedule request to `web/schedule.php`, deployed as `api/tipoff-schedule.php`. PHP validates request parameters and calls `api/schedule-runtime.php`. It invokes the Linux build of `TipoffCheck --web-cached` with a five-second process limit, returning fresh or saved schedules without network waits. Saved responses preserve their original freshness and use Saved listings labels. Stale/missing caches trigger detached `--web` refreshes with an 85-second process limit, isolated locks for sport/date/time zone, and a 30-second retry backoff. Missing data returns HTTP 202 while a refresh is active; the browser polls with an eight-second per-request timeout and a 95-second overall bound. Available followed games render immediately. Completed background results replace saved listings automatically while polling; failed requests retain the matching in-memory snapshot. Five global refresh slots bound concurrency, and hourly cleanup removes inactive job records older than one day. The executable and its writable schedule cache are outside the web root. The preview server remains available for local development.

Build the production executable from this repository in the official `swift:6.3-jammy` image for `linux/amd64` with `swift build -c release --static-swift-stdlib --product TipoffCheck`, then strip the release executable. Verify its shared dependencies with `ldd` and run it as the web user against live feeds before exposing the routes. Keep the cache across executable replacements and web release rollbacks.

- NBA.com with ESPN fallback for NBA, ESPN for NFL and WNBA, and the respective league feed with ESPN fallback for NHL and MLB. Carry the Nuggets Altitude supplement only with agreement on date, opponent, home/away, and tipoff. Keep regional footnotes and original freshness on saved results.
- Keep saved schedules separate by sport, local date, and time zone. Preserve each sport’s working snapshot through upstream errors or malformed data. Show per-sport source, timestamp, fallback or saved state, and unavailable state as applicable. Only display “No games scheduled” after a valid empty result for the selected day. One league failure should leave other leagues usable.
- Preserve native display ordering, including national NBA listings first and Nuggets priority within each group, plus Broncos, Avalanche, and Rockies priority in their respective sports. Use calendar days across time-zone boundaries and daylight saving transitions. Persist only schedule and broadcaster fields. Exclude scores, standings, and live telemetry, and avoid inferring streaming eligibility or local rights.

## Link preview and integration checks

The page uses **Tipoff** and “Game times and broadcast listings for the NBA, NFL, WNBA, NHL, and MLB” in its initial HTML metadata. The preview uses the existing 1920 × 1080 [Tipoff banner](https://www.jimmyweber.com/assets/img/projects/tipoff-banner.png) already hosted by JimmyWeber.com. The image was fetched with a preview crawler user agent. Inspect the final crop in Messages during live verification. See [link preview requirements](https://github.com/jimmytheghost/agentic-toolkit/blob/main/core/LINK-PREVIEWS.md).

Before release, verify both shortcuts, direct visits and reloads, phone and desktop layouts, keyboard use, date navigation around midnight and daylight saving changes, and schedule behavior with fresh, empty, failed, and saved feeds. Check the actual preview image and crawler metadata on both URLs. Record the deployment file list, verification results, and rollback in the website workspace.

Release `tipoff-web-20261105-01` was published November 5, 2026 using the website’s frozen deployment workflow. The release includes the guide HTML, CSS, JavaScript, PHP endpoint, Apache routes, portfolio registry, sitemap policy, and regenerated sitemap. The deployment workspace retains the release plan, backups, and guarded rollback. For this release the staged deploy worker explicitly allowed the root `.htaccess` while retaining baseline and symlink checks.

Verified the canonical route, alias and trailing slash redirects, portfolio link, sitemap, invalid-request response, five public league endpoints, and a narrow-browser NFL filter. A preview crawler could read the metadata and fetch the existing PNG. Messages rendering remains untested. The production origin received HTTP 403 from NBA.com and HTTP 406 from MLB.com during verification, so those two feeds showed ESPN fallback.


## Approved guide redesign publication — November 6, 2026

Published release `tipoff-web-20261106-02` at the existing canonical URL, from approved commit `e75154c` plus versioned CSS/JS URLs (`20261106-01`). Installed only `tip-off.html`, `assets/css/tipoff-guide.css`, and `assets/scripts/tipoff-guide.js`; staged output was formatted with the existing website Prettier. The backend, cached schedules, runtime executable, routing, portfolio registry, and sitemap were preserved.

The isolated deployment workspace under Tipoff’s ignored build directory retains the frozen plan, payload, publication and verification results, operations note, server backup location, and guarded rollback command. It uses unmodified copies of the website deployment tools and reads the existing connection configuration without copying credentials or modifying sibling projects. The first read-only preparation was superseded before publication; only release 02 was published.

All eight release HTTP assertions and installed-file checksums passed. Four guide/alias/slash routes passed initial metadata and 1920 × 1080 PNG checks with both browser and Facebook crawler agents (eight page/image checks). Live league endpoints returned NBA 9 (ESPN fallback), NFL 0, WNBA 0, NHL 3, and MLB 0 for November 6 in America/Denver. One initial NBA request returned HTTP 503; retry returned the valid fallback schedule. Live All Games expansion, NBA/NHL filters, date controls, and narrow layout were checked. Actual Messages rendering remains untested.


## Additional Nuggets broadcast logos — November 6, 2026

Published `tipoff-web-20261106-03`, replacing only `assets/scripts/tipoff-guide.js` and `tip-off.html`. Added distinct Altitude 2 / ALT2, Altitude+, and NBA TV marks with source names retained for accessibility and fallback. Versioned frontend URLs now use `20261106-03`. NBA TV remains excluded from national highlights. All eight release assertions and installed-file checksums passed. Source assets returned the expected MIME types and both PNGs have transparency. Local November 7 Nuggets listings loaded all three logos. Backup, frozen payload, verification, and guarded rollback records remain in the isolated deployment workspace.


## Consistent icon spacing — November 6, 2026

Published `tipoff-web-20261106-05` with shared 0.5 rem gaps for broadcaster groups, regional-label/icon pairs, and team-logo/name pairs. Logos now reserve only their proportional image box within size caps; natural dimensions are applied after load so SVGs with percentage dimensions remain visible. National groups retain the fixed-width column and away-logo alignment. Frontend asset versions use `20261106-05`.

Only guide CSS, JavaScript, and HTML were replaced. All eight deployment assertions, three installed hashes, and four canonical/alias link-preview checks passed. The isolated deployment workspace retains the frozen payload, backup/rollback details, and evidence. Read-only preparation 04 was superseded during local QA and was never published. Source providers, schedules, caches, and routing were unchanged.


## Loading repair — November 6, 2026

Deployed `tipoff-web-loading-20261106-01` and a compatible Linux `TipoffCheck` with the new read-only `--web-cached` mode. The older per-sport lock and synchronous refresh could queue requests for up to 85 seconds and produce 503 responses even when saved schedules existed. The repaired endpoint serves typed saved data first and refreshes outside the HTTP request. Saved snapshots, source labels, broadcaster fields, and original freshness remain intact.

The web release adds `api/schedule-runtime.php` and replaces `api/tipoff-schedule.php`, guide JavaScript, and guide HTML (asset version `20261106-06`). The runtime executable was installed separately with a retained backup and hash guard; the ordinary `--web` mode remains compatible. Frozen plans, runtime backup/rollback details, and timing evidence remain in the isolated deployment workspace.

Validation: 57 native tests passed, 7 cache-only integration tests passed, the final PHP runtime regression run passed all 9 cases, and 4 client loading checks passed. The macOS app packaged successfully. The Linux executable built with static Swift libraries, resolved its production dependencies, and read the real saved NBA cache as the web user. A live native TipoffCheck returned 3 NHL games. All 9 web deployment assertions passed. Six concurrent live requests across several dates returned within 0.28–0.99 seconds: cached schedules were HTTP 200, and uncached dates were HTTP 202. Live navigation between November 7 and November 8 loaded followed games without queuing behind source refreshes.


## Section heading position — November 7, 2026

Published `tipoff-web-20261107-01`: the date selector now comes first, followed by the conditional Following / National Broadcasts heading in the page body, above the game cards, at every screen width. Only HTML and CSS changed; scheduling and cached-first loading are unchanged. Versioned frontend URLs use `20261107-01`. Local checks covered 498 px and 325 px, and the live November 8 view confirmed the Broncos card below Following. All nine release assertions and both installed hashes passed. Backup/rollback details and screenshot evidence are retained in the isolated deployment workspace.


## Reversible flat-surface pass — November 7, 2026

Published `tipoff-web-flat-20261107-01`, replacing only HTML and CSS (asset version `20261107-02`). The authored stylesheet contained no CSS gradients; this pass flattens the layered surface treatment: card headers and game rows share one solid fill, row striping is removed in flat mode, and collapsed/empty sections use muted text instead of whole-row brightness filters. Network/team artwork and schedule behavior are unchanged.

The `tipoff-flat` class on the body enables scoped overrides. Removing that class restores the original styling, which remains intact in the CSS. This rollback switch was tested locally in both directions. See [flat-style rollback](docs/FLAT-STYLE-ROLLBACK.md). The deployment workspace retains the prior HTML/CSS backup, frozen release, and guarded live rollback command. All nine release assertions passed; local checks covered the fixed fill, collapsed rows, and a 325 px layout without horizontal overflow. Live headers and rows used the same solid color with background images set to none.


## Header count alignment — November 7, 2026

Published `tipoff-web-headers-20261107-01`: the shared header now groups its name and game count with baseline alignment, including the National marker when present. Source/freshness stays right-aligned and can wrap below the intact name/count group at narrow widths. Flat styling and its rollback switch remain unchanged. Only guide HTML, CSS, and JavaScript changed; frontend version `20261107-03`.

Local November 8 Broncos measurements showed identical text bounds for National and 1 GAME. The 325 px view had no horizontal overflow. All nine release assertions and all three installed hashes passed. Frozen release, backup/rollback details, and screenshot evidence remain in the isolated deployment workspace.


## Compact Following rows — November 7, 2026

Published `tipoff-web-following-20261107-01`, replacing only guide HTML/CSS/JavaScript (asset version `20261107-04`). Following games now use the same fixed broadcaster column, matchup, and start time as national games. National networks are shown when provided; otherwise the compact row selects a listed Altitude / Altitude 2 network (preferring the matched Altitude guide), or the first source-listed video broadcaster. Expanding reveals all original video listings and regional labels, plus Altitude networks, show times, footnotes, and original freshness. Simple national-only rows remain plain. All Games and the flat-mode rollback switch are preserved.

Ten compact-selection cases and four existing client-loading tests passed. Browser checks covered Altitude 2, NHL ALT, Broncos CBS, Nuggets disclosure/keyboard behavior, and a 325 px layout without horizontal overflow. Live November 9 matchup columns align exactly across Following/NBA/NFL; expanded details retain ALT2/KTVD, KUSA, and the original Altitude data. All nine deployment assertions, three installed hashes, and four browser/crawler preview checks passed. The isolated deployment workspace retains the frozen release, backups, guarded rollback command, and screenshot evidence. Providers, schedule caches, runtime executable, routing, and portfolio data were unchanged.


## Shared header separator — November 7, 2026

Published `tipoff-web-divider-20261107-01`, CSS and HTML only (asset version `20261107-05`). A faint one-pixel bottom stroke separates the shared Following / National / All Games headers from their rows without changing layout dimensions or flat fills. Local and live November 8 Broncos/NFL views were checked. All nine release assertions, two installed hashes, and four browser/crawler preview checks passed. The isolated deployment workspace retains the frozen release, backup, guarded rollback command, and screenshot evidence.


## Date navigation component and footer — November 7, 2026

Published `tipoff-web-navigation-20261107-01`: CSS and HTML only, asset version `20261107-06`. The date selector now has a bordered solid container, visible previous/next button surfaces, and lime Today text. Existing 44 px button targets, accessible labels, keyboard focus, and calendar-day behavior remain. A viewport-height flex layout places the footer at the bottom of short pages and after expanded content on long pages, with no trailing gap or fixed overlay.

Local checks covered short pages, expanded All Games, next-day/Today interaction, and 325 px layout without horizontal overflow. Live date controls and footer placement passed. All nine deployment assertions, two installed hashes, and four canonical/alias browser/crawler preview checks passed. Backup, frozen payload, guarded rollback command, and screenshot evidence remain in the isolated deployment workspace.


## Date toolbar refinement — November 7, 2026

Published `tipoff-web-date-refinement-20261107-01`, CSS and HTML only (frontend version `20261107-07`). Replaced the enclosed date box with a transparent 24 rem toolbar anchored by one thin bottom rule, muted arrow controls, and a neutral outlined Today button. Existing 44 px targets, keyboard focus/activation, calendar-day navigation, and bottom footer are preserved. Local 1261 px desktop and 325 px mobile checks passed without overflow; live appearance verified. All nine release assertions, two installed hashes, and four browser/crawler preview checks passed. The isolated deployment workspace retains the frozen payload, backups, rollback command, and screenshot evidence.


## Responsive date placement — November 7, 2026

Published `tipoff-web-responsive-date-20261107-01`, HTML/CSS/JS only (asset version `20261107-08`). At 64 rem / 1024 px and wider, the same date-control group moves into the header between brand and back link. On tablet/mobile it returns above the section heading in main and spans the full content width. Desktop has no separate baseline; the body toolbar retains its thin rule. Relocation preserves selected date, listeners, and focus without duplicate IDs/controls. Footer behavior remains intact.

Local checks covered 1261 px desktop, 833 px tablet, and 325 px mobile, including date/focus preservation through resizing, no overflow, and keyboard Today. Four client-loading checks, nine release assertions, three installed hashes, and four browser/crawler preview checks passed. Live responsive placement was verified. Frozen release, backup, guarded rollback command, and screenshot evidence remain in the isolated deployment workspace.


## Adaptive team names — November 7, 2026

Published `tipoff-web-adaptive-names-20261107-02`: guide HTML/CSS/JS only, asset version `20261107-09`. Every matchup now uses full names when both fit in its actual column, shortening both by removing recognized locations when necessary. Measurements include logos, separator, and gaps; resizing, font loading, and opening hidden schedules update the choice. Smaller cards can therefore shorten names even on desktop. Hover titles retain full display names. The NBA-only display lookup fills locations for nickname-only feed entries using the official NBA team list; existing full/unknown source names and snapshots stay intact.

Local checks covered desktop Broncos/NFL full names, narrow short names, hidden All Games opening, restoration on widening, and NBA/NHL names in full schedules versus smaller Following cards. Twenty web cases passed (6 display names, 10 broadcaster selections, 4 loading), plus nine deployment assertions, three installed hashes, and four browser/crawler preview checks. Live fitting verified. Read-only preparation 01 was superseded before publication; the isolated deployment workspace retains release 02’s frozen payload, backups, rollback command, and screenshots.


## Broadcaster logo contrast and sizing — November 7, 2026

Published `tipoff-web-logo-scale-20261107-01`: HTML/CSS/JS only, frontend version `20261107-10`. NBC now uses Wikimedia Commons’ [white-letter/colored-peacock asset](https://commons.wikimedia.org/wiki/File:NBC_2023_white_logo.svg), and ESPN uses the [clean vector wordmark](https://commons.wikimedia.org/wiki/File:ESPN_wordmark.svg) with the existing white-logo filter. Both source SVGs returned 200 with valid SVG MIME/content. Source names and text fallbacks are preserved.

Network marks now share proportional 3 rem width / 1.4 rem height caps in all contexts, removing the smaller summary-only caps. Multiple networks wrap within the same fixed column, retaining away-logo alignment and the shared gap. Longer groups can increase row height. Local 325/1261 px layouts had no horizontal overflow; live November 10 rendering checked. Twenty existing web cases, nine release checks, three installed hashes, and four browser/crawler preview checks passed. Backup, frozen payload, guarded rollback command, and screenshot evidence are retained in the isolated deployment workspace.


## Horizontal inline network groups — November 7, 2026

Published `tipoff-web-logo-row-20261107-01`, CSS and HTML only (asset version `20261107-11`). Inline network groups remain on one horizontal line, shrinking proportionally within their fixed column only when necessary. Larger single-logo sizing, white NBC lettering, clean ESPN wordmark, shared spacing, and matchup alignment are preserved; expanded broadcast lists can still wrap. Local 540/325 px checks and live November 10 confirmed no stacking or horizontal overflow. All nine release assertions, two installed hashes, and four browser/crawler preview checks passed. Frozen payload, backup/rollback records, and screenshot evidence remain in the isolated deployment workspace.


## Calendar picker, basketball branding, and NBCSN — November 7, 2026

Published `tipoff-web-calendar-brand-20261107-01`: guide HTML/CSS/JS plus the new 232 × 230 header PNG (frontend version `20261107-12`). The supplied screenshot artwork is stored unchanged in `web/brand-mark.png`; an inline SVG clips it to the ball and tints it with the inherited lime color while making seams/background transparent. The mark sits left of Tipoff. Native app artwork and existing social preview artwork are preserved. Preview routing serves the same asset path.

The date button opens the native browser calendar; selected dates parse to local noon and invalid/cleared values are ignored. Today/arrows synchronize the picker; accessible labels include the selected date and focus returns after selection. A native field fallback is implemented for browsers without showPicker. NBCSN/NBC Sports Network map to the distinct [NBCSN vector](https://commons.wikimedia.org/wiki/File:NBCSN_Logo_2025.svg), rendered white while retaining source names.

Forty web cases passed (20 new calendar/date cases in two time zones and 20 existing regressions), plus syntax/whitespace checks. Local and live calendar selection, keyboard dismissal, desktop/mobile relocation, header tint, and NBCSN rendering were verified. All ten release assertions, four installed hashes, and four browser/crawler preview checks passed, including header asset MIME/checksum. No native provider/runtime/cache code changed. The isolated deployment workspace retains frozen release, backup/rollback details, and screenshots. Native calendar panels are not included in the browser screenshot capture; opening/selection were verified through its accessible table and updated guide date.


## Site-themed calendar — November 7, 2026

Published `tipoff-web-themed-calendar-20261107-01`, HTML/CSS/JS only (asset version `20261107-13`), replacing the prior native date popup with a custom HTML popover. It uses the same dark solid surface, thin border, typography, and lime accents as the guide. Selected day is filled lime; today is outlined. The six-week calendar includes month navigation, adjacent-month dates, and Today, with local-noon date arithmetic unchanged. Header/logo assets, network logos, schedule providers, and caches are unchanged.

Accessible grid behavior includes one roving tab stop, full day labels, selected/current state, arrow/Home/End navigation, PageUp/PageDown month navigation (Shift for year), Enter/Space selection, Escape focus return, and outside-click/trigger dismissal. The panel stays within viewport bounds and closes when responsive relocation moves the controls. Local 325 px and 1261 px layouts, selection/month navigation/keyboard/Today/dismissal were checked. Fifty-eight web cases passed (18 new grid/month cases plus 40 regressions), ten release assertions, three installed hashes, and four preview checks passed. Live styled popup/selection verified and screenshot captured; native-panel screenshot limitations in the prior release no longer apply. The isolated deployment workspace retains frozen payload, backups, guarded rollback, and evidence.


## Date chevron removed — November 7, 2026

Published `tipoff-web-date-arrow-20261107-01`: CSS/HTML only, frontend version `20261107-14`. Removed the decorative dropdown arrow beside the date; the text button still opens the themed calendar. Previous/next navigation remains unchanged. Live appearance and calendar selection verified; ten release assertions, two installed hashes, and four preview checks passed. Frozen release, backups, rollback command, and screenshot remain in the isolated deployment workspace.


## Dark-background team artwork — November 7, 2026

Published `tipoff-web-dark-teams-20261107-01`: JavaScript and HTML only, frontend `20261107-15`. Shared team rendering prefers ESPN’s dark-background marks (source metadata rel=[full,dark]), retaining league aliases and retrying default artwork on failure. The 30 MLB numeric IDs are mapped from official MLB metadata to ESPN logo slugs; original MLB SVGs remain a final fallback and unknown IDs keep the native SVG. Names remain if every image fails. Sizes, broadcaster artwork, schedule providers, and cached data are unchanged.

All 139 dark assets decoded successfully across NBA/NFL/WNBA/NHL/MLB; default/dark examples were reviewed at row size against the site surface. Seventeen routing/fallback tests plus 58 regressions passed (75 web cases); native app tests were not needed for this frontend-only change. Local/live NBA/NHL and representative NFL rendering verified. All ten release assertions, two installed hashes, and four browser/crawler preview checks passed. The ignored logo-review directory retains source metadata and image audit/comparison evidence; the isolated deployment workspace retains the frozen release, backups, rollback command, and live screenshots.


## Canonical URL rename — November 7, 2026

Published `tipoff-web-url-20261107-01`, frontend `20261107-16`: canonical and Open Graph URLs, header/portfolio links, frontend asset/API paths, project registry, and generated sitemap now use `/tipoff`. The physical server file remains `tip-off.html`. The maintained Apache block is [web/apache-tipoff-routes.conf](web/apache-tipoff-routes.conf); replace only the existing Tipoff block when integrating it. `/tip-off`, `/sports`, slash variants, and direct `/tip-off.html` redirect to `/tipoff` with query strings preserved. Both old and new CSS/JS/schedule prefixes remain available for cached clients. Redirects use the site's existing 302 policy, allowing rollback without permanent browser redirect caching.

The protected routing block was installed separately with exact before/after hash guards, an unchanged-file check, ownership/mode preservation, backup, atomic replacement, and Apache syntax validation. The normal unmodified publisher installed five files, including the regenerated sitemap. Rollback restores the web release first, then the routing block; exact commands and backups remain in the ignored publication operations log. No sibling workspace, native provider, runtime, or cache changes.

Validation: 91 web checks/cases (16 local route checks plus 75 existing cases), 17 release assertions, six query-preserving redirect checks, and 14 browser/crawler metadata/image checks passed. The sitemap retains 407 URLs with only Tipoff's URL replaced. Live browser navigation from `/tip-off` reached `/tipoff`; next-day listings and the calendar loaded. Screenshot: `/tmp/tipoff-canonical-url-live.jpg`. Messages rendering remains untested. Native app tests executed: 0 for this website routing change.


## Lime basketball favicon — November 7, 2026

Published `tipoff-web-favicon-20261107-01`: `tip-off.html` plus `assets/img/projects/tipoff-favicon.svg`. Source [web/favicon.svg](web/favicon.svg) embeds the existing supplied `web/brand-mark.png` without external dependencies, reusing the header’s crop and transparency filter with explicit lime `#c8fa54`. The guide declares the SVG favicon with a versioned asset URL; local preview serves it too. No global site favicon, routing, schedules, or native app changes. Rollback uses the normal publisher’s frozen backup.

All 5 release assertions, both installed hashes, 16 existing local route checks, and 6 browser/crawler preview checks passed. Live browser verified the declared favicon URL and visibly rendered the lime basketball asset. Screenshot: `/tmp/tipoff-lime-favicon-live.jpg`. Browser tab icon caching can delay an existing tab’s update; actual Messages rendering remains untested. Native app tests executed: 0 for this asset/HTML-only release.


## Consolidated schedule status — November 7, 2026

Published `tipoff-web-status-20261107-01`, frontend `20261107-17`: HTML/CSS/JS only. Cards now show their identity and count without source/freshness labels. A compact, initially closed Schedule status disclosure below All Games shows loading/loaded, saved, and unavailable counts; opening it reveals one row for each of the five sports. Rows preserve the source, original fetched timestamp, Saved listings label, explicit fallback identity, and Altitude supplement warnings. Routine loading/unavailable notices also live there. Game-specific broadcast details retain their own listings/notes. The status panel remains independent of All Games and its filters, and updates on date changes with aborted old requests ignored.

All 75 existing web unit cases and 16 route checks passed (91 total); JavaScript syntax and Git whitespace passed. No new unit tests or native app tests for this presentation change. Eight release assertions, three installed hashes, and six browser/crawler preview checks passed. Local expanded panel verified five source rows. Live November 9 showed five saved sports with original 2:11 PM timestamps and fallback labels; All Games expansion retained zero card freshness nodes, five source rows, and no horizontal overflow. Screenshot: `/tmp/tipoff-bottom-status-live.jpg`. Frozen release and normal rollback records remain in the ignored publication workspace. Messages rendering remains untested.


## Schedule status summary refinement — November 7, 2026

Published `tipoff-web-status-summary-20261107-01`, frontend `20261107-18`: JavaScript and HTML only. Schedule status remains collapsed by default. All five successful results, including saved results, produce “All schedules loaded” with the browser-local completion date and time. This is the current load completion time; the expanded rows retain original data freshness, saved/fallback labels, and error details. Partial/failed loads show counts such as “4 loaded - 1 error”, with pending loading counts when applicable. Seven summary cases and the collapsed-default markup check passed, plus 16 existing local route checks. Eight release assertions, two installed hashes, and six browser/crawler preview checks passed. Native app tests executed: 0. Frozen payload/backup/rollback retained in ignored publication operations notes. Messages rendering remains untested.


## Status message alignment — November 7, 2026

Published `tipoff-web-status-alignment-20261107-01`, frontend `20261107-19`: CSS/HTML only. Removed the static “Schedule status” summary label, leaving only the success timestamp or loading/error counts and disclosure indicator. The collapsed row uses center alignment and symmetric padding with its existing 44 px target. The initial HTML reads “Loading schedules…” until the existing script updates it; expanded per-sport information is unchanged.

Seven existing summary cases, the collapsed-default markup check, and 16 existing route checks passed. Eight release assertions, two installed hashes, and six browser/crawler preview checks passed. Native app tests executed: 0. Local measured text spacing was 13.74 px above and 13.75 px below. Frozen release and guarded rollback remain in the ignored publication workspace. Messages rendering remains untested.


## Logo-only matchups when names do not fit — November 7, 2026

Published `tipoff-web-compact-matchups-20261107-01`, frontend `20261107-20`: CSS/JS/HTML only. Shared matchup rendering now measures full and shortened name widths independently. If even the shortened pair will not fit and both team images loaded successfully, it shows `[logo] @ [logo]`. Wider columns restore shortened/full names as space allows. Images keep their size; team wrappers expose full accessible names and hover titles. Missing/loading/failed images retain text, and image load/failure, font changes, resize, and opening hidden schedules recheck the fit. Original source names and snapshots are unchanged.

Eight new sizing/resize/image-fallback cases and 82 existing web unit cases passed (90 unit cases), plus 16 route checks and the existing collapsed-status markup check. JavaScript syntax/Git whitespace passed; native app tests executed: 0. Local 369 px showed two logo-only Following matchups, while 1261 px restored shortened names in wider cards. Eight release assertions, three installed hashes, and six browser/crawler preview checks passed. Live 369 px showed both Following rows in logo-only mode with no horizontal overflow; wider live columns restored names. Screenshot: `/tmp/tipoff-logo-only-matchups-live.jpg`. Frozen release and guarded rollback remain in ignored publication operations notes; Messages rendering remains untested.


## Mobile typography, larger marks, and home branding — November 7, 2026

Published `tipoff-web-mobile-polish-20261107-01`, frontend `20261107-21`: HTML/CSS/JS plus new `assets/img/projects/tipoff-home-mark.svg`. Source [web/home-mark.svg](web/home-mark.svg) copies Jimmy’s supplied `JimmyTheGhost-Skull.svg` vector, changing only the root fill to the site accent `#c8fa54`; the sibling website files are untouched. Both home links use the skull instead of text/chevrons, keep accessible back-link labels, and retain 44 px targets. Local preview serves the new asset.

Logo-only matchups use 1.8 rem team marks (text-bearing rows retain 1.4 rem); fitting measures the normal size first so text restoration stays stable across resizing. Up to 24 rem wide, Today appears above the unbroken date without a separator; wider toolbars retain Today · date. Calendar/date changes and accessible full-date labels remain intact. The status summary is smaller, bold, uppercase, and spaced; the no-national-listings message matches that typography with fainter #727f91. The status disclosure stays collapsed and centered.

All 90 existing web unit cases, the collapsed-status markup check, and 16 existing local route checks passed. JavaScript syntax/Git whitespace passed; native app tests executed: 0. Nine release assertions, four installed hashes, and six browser/crawler preview checks passed. Local 319 px verified stacked Today/date, two loaded skull marks, larger logo-only matchups, and no horizontal overflow; 1261 px verified inline date labels and both home marks. Frozen release and rollback remain in ignored publication operations notes. Messages rendering remains untested.

Live 319 px verification confirmed Today above the date, four 28.8 px team marks, both accessible skull links, faint uppercase empty text, and no horizontal overflow. Screenshot `/tmp/tipoff-mobile-polish-live.jpg`.


## Mobile viewport audit — November 7, 2026

The reported right-edge cutoff was traced to the earlier full-page screenshot capture. Live page geometry fits without horizontal scrolling: loaded landing and expanded All Games at 319 px, expanded All Games at 369 and 390 px, and the calendar and expanded status at 319 px. Calendar bounds were x=7.99–311.16 px. Corrected viewport capture: `/tmp/tipoff-mobile-fits-screen.jpg`. No frontend edits or deployment; `tipoff-web-mobile-polish-20261107-01` remains current. See the validation log for exact measurements.


## Empty national heading — November 7, 2026

Published `tipoff-web-empty-national-20261107-01`, frontend `20261107-22`: JavaScript/HTML only. Highlight headings follow actual rendered groups as each league loads, avoiding an empty National Broadcasts headline during loading or after a valid empty result. The faint empty message now reads “No national broadcasts listed.” Both headings return as appropriate when a selected day has games. National followed games remain counted as national coverage for the empty-message decision, so that message does not falsely deny coverage already shown in Following. Failed schedules remain in the bottom status panel without an empty-result claim.

Four existing client-loading cases and 16 existing route checks passed; JavaScript syntax/Git whitespace passed. Native app tests executed: 0; no new unit tests. Local November 7 verified hidden national heading and revised message; November 8 restored the national heading beside Following and cleared the message. Nine release assertions, two installed hashes, and six browser/crawler preview checks passed. Frozen release/guarded rollback remain in ignored publication operations notes. Messages rendering remains untested.

Live verification repeated both November 7 (national headline hidden, revised empty message) and November 8 (national headline restored with games). Screenshot: `/tmp/tipoff-empty-national-live.jpg`.


## Empty-message spacing — November 7, 2026

Published `tipoff-web-empty-spacing-20261107-01`, frontend `20261107-23`: CSS/HTML only. Empty national groups no longer leave a blank grid margin. The empty-message section has no bottom margin, and All Games uses a 0.75 rem top margin / 0.5 rem top padding only when that message is present. Local measured message-to-divider gap reduced from 44 px to 12 px. Populated national sections retain existing spacing.

Formatting/Git whitespace passed; no unit or native app tests executed for this CSS-only adjustment. Nine release assertions, two installed hashes, and six browser/crawler preview checks passed. Frozen release and guarded rollback remain in ignored publication operations notes. Messages rendering remains untested.

Live empty-state gap verified at 12 px, with the original 32 px All Games margin preserved on November 8 with national games. Screenshot: `/tmp/tipoff-tighter-empty-spacing-live.jpg`.


## Footer status disclosure — November 7, 2026

Published `tipoff-web-footer-status-20261107-01`, frontend `20261107-24`: HTML/CSS/JS only. Moved the existing status disclosure from the main body to the footer’s right side beside the skull home link. Its collapsed container has no border, retains the + control and right-aligned timestamp/error message, and stays closed by default. Opening it displays the same five source/freshness/error rows in a borderless floating container above the footer. The panel is bounded to the viewport, scrolls if needed, and leaves footer/page layout in place. Native keyboard activation remains; Escape closes with focus return and outside-click closes it too.

Seven existing status-summary cases and the collapsed-default markup check passed, plus 16 existing local route checks. JavaScript syntax/Git whitespace passed; native app tests executed: 0. Local checks at 319/513/1261 px confirmed upward placement, zero border, no horizontal overflow, Escape and outside dismissal. Nine release assertions, three installed hashes, and six browser/crawler preview checks passed. Frozen release and guarded rollback remain in ignored publication operations notes. Messages rendering remains untested.

Live 513 px verified footer placement, border 0, five details rows opening upward, and no horizontal overflow. Closed/open captures: `/tmp/tipoff-footer-status-closed-live.jpg`, `/tmp/tipoff-footer-status-open-live.jpg`.


## Two-line mobile footer status — November 7, 2026

Published `tipoff-web-footer-status-lines-20261107-01`, frontend `20261107-25`: HTML/CSS/JS only. Successful-load status renders a separate label and semantic time element. At up to 32 rem wide, “All schedules loaded” is the first line and the unbroken date/time is the second; larger widths keep both inline with a space. Loading/error count wording, original per-source freshness, the collapsed default, + control, and upward panel behavior are unchanged.

Seven existing status-summary cases and collapsed-default markup check passed, plus 16 existing route checks. JavaScript syntax/Git whitespace passed; native app tests executed: 0. Local 319 px verified label y=700 px and single-line timestamp y=715 px, height=15 px; `scrollWidth=319`. At 1261 px the timestamp is inline. Nine release assertions, three installed hashes, and six browser/crawler preview checks passed. Frozen release/guarded rollback remain in ignored publication operations notes. Messages rendering remains untested.

Live 383 px verified the two-line footer with a single-line timestamp, collapsed disclosure, and no horizontal overflow. Screenshot: `/tmp/tipoff-footer-two-lines-live.jpg`.


## Quieter footer timestamp — November 7, 2026

Published `tipoff-web-footer-timestamp-20261107-01`, frontend `20261107-26`: CSS/HTML only. The successful-load timestamp uses 0.9 em (9 px), weight 500, and muted #8794a7; its label retains 10 px, weight 700, and the existing brighter muted color. Mobile two-line layout, wider inline layout, status wording, and panel behavior are unchanged. Formatting/Git whitespace passed; no unit/native tests executed for this CSS-only adjustment. Nine release assertions, two installed hashes, and six browser/crawler preview checks passed. Frozen release/guarded rollback remain in ignored publication operations notes. Messages rendering remains untested.

Live computed styles confirmed the timestamp is 9 px / 500 / RGB(135,148,167), against the label’s 10 px / 700 / RGB(174,187,208). Screenshot: `/tmp/tipoff-quieter-footer-timestamp-live.jpg`.


## Right-aligned header metadata and stacked desktop footer — November 7, 2026

Published `tipoff-web-header-metadata-20261107-01`, frontend `20261107-27`: HTML/CSS/JS only. Shared card headers now keep the name on the left and place the game count in a separate right-aligned group. Following’s National marker joins that group before the count. The group is vertically centered in each header, including All Games. The footer success label and smaller, fainter date/time now use two lines at every width.

Seven existing status-summary cases and collapsed-default markup check passed, plus 16 existing route checks. JavaScript syntax/Git whitespace passed; native app tests executed: 0. Local November 8 headers had 12 px right insets and center offsets within 0.004 px; 319 px had no horizontal overflow. At 1261 px both footer nodes were block-level with the timestamp 15 px below the label. Nine release assertions, three installed hashes, and six browser/crawler preview checks passed. Frozen release/guarded rollback remain in ignored publication operations notes. Messages rendering remains untested.

Live November 8 confirmed right-aligned, centered National/count groups; desktop 1261 px confirmed the timestamp below its label. Screenshot: `/tmp/tipoff-right-header-metadata-live.jpg`.


## Softer counts and styled detail labels — November 7, 2026

Published `tipoff-web-detail-labels-20261107-01`, frontend `20261107-28`: CSS/HTML only. Shared game counts now use 9 px / weight 500 / #8794a7, matching the footer timestamp’s smaller/fainter hierarchy while keeping their centered right alignment. National markers retain their original lime emphasis. Expanded Following card headings “Broadcast listings” and “Altitude details” use 10 px / weight 700 lime uppercase text with 0.12 em letter spacing and a faint trailing rule. Source-listed broadcasters, notes, times, and freshness text are unchanged.

Formatting/Git whitespace passed; no unit/native app tests executed for this CSS-only adjustment. Local expanded Nuggets verified both styled headings, softer counts, and no overflow down to the browser’s reported 266 px viewport. Nine release assertions, two installed hashes, and six browser/crawler preview checks passed. Frozen release/guarded rollback remain in ignored publication operations notes. Messages rendering remains untested.

Live expanded Nuggets verified both heading styles and softer counts without horizontal overflow. Screenshot: `/tmp/tipoff-detail-labels-live.jpg`.


## Compact Altitude information — November 7, 2026

Published `tipoff-web-altitude-compact-20261107-01`, frontend `20261107-29`: HTML/CSS/JS only. Altitude information now uses 12 px text, tighter paragraph margins, and 10 px freshness text. Source-provided pregame/postgame times share one flex row, each retaining its label; missing times are omitted, and extreme narrow widths can wrap whole timing labels. This shared renderer applies to Following and full-schedule Altitude details. Original networks, footnotes, show times, saved state, and freshness content remain unchanged.

JavaScript syntax, formatting, and Git whitespace passed; no unit/native app tests executed for this presentation change. Local expanded Nuggets verified 12/10 px text and identical pregame/postgame row positions at regular and 319 px widths, with no horizontal overflow. Nine release assertions, three installed hashes, and six browser/crawler preview checks passed. Frozen release/guarded rollback remain in ignored publication operations notes. Messages rendering remains untested.

Live expanded Nuggets verified smaller text and both show times on one row, without horizontal overflow. Screenshot: `/tmp/tipoff-compact-altitude-live.jpg`.


## Altitude freshness in footer status — November 7, 2026

Published `tipoff-web-altitude-status-20261107-01`, frontend `20261107-30`: JavaScript/HTML only. Removed the Altitude updated / Saved Altitude data timestamp from the shared game-detail renderer, so both Following and All Games keep only the network names, show times, and notes. The expanded footer now has an optional Altitude row after NBA, using the original supplement timestamp and saved label. Duplicate freshness labels are merged without altering source data. The row clears on date changes and stays absent if the selected day has no supplement. It does not add a sixth sport to the load/error counts.

Seven existing status-summary cases and collapsed-default markup check passed, plus 16 existing route checks. JavaScript syntax/Git whitespace passed; native app tests executed: 0. Local November 7 verified no freshness timestamp in main content and six footer rows (five sports plus Altitude), with the supplement’s original fetched time. November 8 removed the optional row and left the five sport rows. Nine release assertions, two installed hashes, and six browser/crawler preview checks passed. Frozen release/guarded rollback remain in ignored publication operations notes. Messages rendering remains untested.

Live verification confirmed Altitude freshness appears only in the footer panel, preserving the original 3:38 PM value separately from the current load completion time. Screenshot: `/tmp/tipoff-altitude-footer-status-live.jpg`.


## Altitude details limited to times and notes — November 7, 2026

Published `tipoff-web-altitude-times-notes-20261107-01`, frontend `20261107-31`: JavaScript/HTML only. Removed the repeated Altitude network-name paragraph from the shared details renderer. Networks remain in the broadcast list above; Altitude details contain only source-provided pregame/postgame times and notes. When neither is provided, the empty Altitude subsection is omitted. Footer freshness and original source data are unchanged.

JavaScript syntax, formatting, and Git whitespace passed; no unit/native tests executed for this small rendering change. Nine release assertions, two installed hashes, and six browser/crawler preview checks passed. Frozen release/guarded rollback remain in ignored publication operations notes. Messages rendering remains untested.

Live expanded Nuggets confirmed only show times under Altitude details, with all network listings retained above. Screenshot: `/tmp/tipoff-altitude-times-notes-live.jpg`.


## Heading-free show times — November 7, 2026

Published `tipoff-web-altitude-inline-20261107-01`, frontend `20261107-32`: HTML/CSS/JS only. Removed “Altitude details” and its separate disclosure heading from the shared renderer. Pregame/postgame times now sit directly below the broadcast listings in the same typography as game counts: 9 px / weight 500 / #8794a7 / 0.08 em / uppercase. Notes remain below in their readable body style. Networks stay above and supplement freshness stays in the footer; original source content is unchanged.

JavaScript syntax, formatting, and Git whitespace passed; no unit/native tests executed for this presentation change. Local expanded Nuggets confirmed no Altitude heading, identical count/time computed styles, and both show times on one row. Nine release assertions, three installed hashes, and six browser/crawler preview checks passed. Frozen release/guarded rollback remain in ignored publication operations notes. Messages rendering remains untested.

Live expanded Nuggets confirmed heading-free show times matching game counts exactly, without horizontal overflow. Screenshot: `/tmp/tipoff-inline-show-times-live.jpg`.


## Portfolio expansion published — November 7, 2026

The expanded portfolio is live at https://www.jimmyweber.com/pages/projects/tipoff/ following Jimmy's explicit publication request. The website release installed the portfolio controller, scoped stylesheet, media manifest, and ten selected original images from `docs/portfolio/`. It uses the Pick a Psych/tzMiniFigs image-and-text layout and shared image lightbox. Alec Miller's video/poster/credit and Jimmy's supplied motivation are preserved. The Windows feature diagram remains labeled, and native production-view renders retain their captions. The reviewed page has no introduction section-button group and centers the video/credit. The browser app at https://www.jimmyweber.com/tipoff was unchanged.

Nine displayed images, seven descriptive sections, video metadata/controls and credit, centered geometry, keyboard lightbox/focus return, dark mode, and 1440/390/325 px layouts passed live checks with no horizontal overflow or JavaScript errors. All 13 installed file hashes and 17 HTTP content/MIME/checksum checks passed. An initial check had an incorrect expected MIME for unchanged shared JavaScript; verification passed after correcting the expectation to the server's valid text/javascript, without changing the frozen payload. Browser and Facebook crawler checks passed for the portfolio canonical metadata and public 1200 × 630 PNG at https://www.jimmyweber.com/assets/img/projects/tipoff/tipoff-social-v1.png. Actual Messages rendering remains untested.

Image source/provenance and reproducible composition scripts remain in `docs/portfolio/`. No reference captures, source snapshots, private data, native app code, or schedule runtime files were published. Website operations retain the release, screenshots, backups, and guarded rollback. Native app tests executed: 0 for this portfolio-only deployment.


## Website background reliability — November 10, 2026

Published `tipoff-web-reliability-20261110-01` (JavaScript version `20261110-01`) to https://www.jimmyweber.com/tipoff. Replaced only the guide JavaScript, HTML script version, PHP schedule runtime, and separately backed-up Linux TipoffCheck executable. Layout, CSS, artwork, routing, and live schedule caches were preserved.

Saved responses render immediately and are polled while the server reports a refresh, including HTTP 200 saved responses. Fresh results replace them automatically. A bounded 45-entry in-memory cache retains the same sport/date/time-zone snapshot through request failures, keeping its original timestamp and a saved/failure label. Date changes abort obsolete responses. Unchanged polling results do not rebuild game rows.

Server admission permits at most five detached refreshes managed by the new scheduler. The child holds both its per-request lock and global slot for its lifetime (including the 85-second timeout). Full capacity returns a pending response without spawning queued workers. Cleanup runs at most hourly, removing inactive request records older than one day while retaining active locks and the fixed admission/slot locks. The Linux reader includes strict NBA broadcaster validation from the native reliability fix.

Validation: 58 Swift tests; 97 JavaScript cases/scenarios; 7 cache integration tests; 16 route checks; 12 PHP 8.1 runtime scenarios; collapsed-status markup and syntax/whitespace checks passed. macOS packaging/signature checks passed. Linux static-Swift build and production dependency resolution passed; production www-data read the existing NBA cache and fetched seven NHL games with the new executable. A separate native NBA check returned six NBA.com games. Production NBA live checking exceeded its 85-second bound; saved NBA data remained available, honestly labeled. No Windows tests were executed.

The deployed three web-file hashes and nine release HTTP assertions passed. Live browser confirmed version 20261110-01, saved NBA rows alongside automatically updated NFL/WNBA/NHL/MLB timestamps, five national rows retained on Today refresh, and no desktop horizontal overflow. Screenshot: /tmp/tipoff-reliability-live.jpg. Eight browser/crawler page and PNG checks passed; actual Messages rendering remains untested. Frozen payload, runtime backup, and guarded rollback procedure are retained in the ignored publication workspace.
