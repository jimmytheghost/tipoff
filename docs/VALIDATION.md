# Validation

Original macOS environment: Apple Silicon macOS, Apple Swift 6.3.3, standalone Command Line Tools. Windows checks use Windows x64 and .NET SDK 9.0.203. Initial personal-use time zone: America/Denver.

## Empty-message spacing — November 7, 2026

- Removed empty national grid spacing and tightened only the empty-message-to-All-Games transition: 0.75 rem top margin / 0.5 rem divider padding. Populated sections retain their existing margins.
- Local geometry: message-to-divider gap reduced from **44.00 px to 12.00 px**. Formatting/Git whitespace passed. **0 web unit tests / 0 native app tests executed** for the CSS-only change.
- Published `tipoff-web-empty-spacing-20261107-01`, frontend `20261107-23`: **2 files, 9 release assertions, 2 installed hashes, 6 browser/crawler preview checks passed**. Live empty-state gap measured 12.00 px; November 8 with a national group retained the original 32 px All Games margin. Screenshot `/tmp/tipoff-tighter-empty-spacing-live.jpg`. No JavaScript/provider/runtime/cache changes. Messages rendering remains untested.

## Empty national heading — November 7, 2026

- Highlight headings now reflect rendered groups during incremental loading and after completion. Empty national sections hide their large heading and show the faint “No national broadcasts listed.” message after successful loading. A followed national game suppresses a false no-national message; source errors remain in the status disclosure.
- **4 existing client-loading cases and 16 existing route checks passed**. JavaScript syntax/Git whitespace passed. **0 new unit tests / 0 native app tests executed** for this presentation change.
- Local November 7: national heading hidden and revised message shown. November 8: Following and National Broadcasts headings present, one national group, empty message cleared. Published `tipoff-web-empty-national-20261107-01`, frontend `20261107-22`: **2 files, 9 release assertions, 2 installed hashes, 6 browser/crawler preview checks passed**. Messages rendering remains untested. No provider/runtime/cache changes.

## Mobile viewport audit after cropped capture — November 7, 2026

- Investigated the reported right-edge cutoff on the live guide. The earlier full-page screenshot clipped the capture; the live document had no horizontal overflow. No frontend code change or deployment was needed.
- At **319 px**, `documentElement.clientWidth` and `scrollWidth` were both **319 px** after schedules loaded. Header, footer, date controls, cards, inline game rows, and status container stayed within the viewport; the two team logos fit before the start-time column without overlapping it.
- Expanded All Games retained matching viewport/scroll widths at **319, 369, and 390 px**. At **319 px**, the calendar stayed within x=**7.99–311.16 px**, and expanding the five-source status panel kept `scrollWidth=319`.
- Saved the complete visible right edge using the browser's viewport screenshot capture: `/tmp/tipoff-mobile-fits-screen.jpg`. Temporary viewport override reset. **0 native app tests / 0 web unit tests executed** for this browser-only audit; existing release `tipoff-web-mobile-polish-20261107-01` remains live.

## Mobile typography and home branding — November 7, 2026

- Enlarged logo-only team marks to **1.8 rem** (normal rows remain 1.4 rem), measuring the normal text layout before resizing artwork to prevent fit-state hysteresis. At up to **24 rem**, Today stacks above the unbroken date and its separator is omitted; wide layouts remain inline. Date/calendar accessible labels remain intact.
- Replaced header/footer back text and chevrons with the supplied skull SVG tinted **#c8fa54**, with accessible back-link labels and 44 px targets. Source vector paths are unchanged; sibling website files are untouched. Status summary uses **0.625 rem / 700 / uppercase / 0.08 em**; the empty national message matches it with faint **#727f91**. Collapsed status centering remains.
- **90 existing web unit cases**, collapsed-status markup check, and **16 existing local route checks passed**. JavaScript syntax/Git whitespace passed. **0 native app tests executed**. Local **319 px**: Today/date stacked, two skull assets loaded, no overflow. Local **1261 px**: date inline with separator and both skull marks present.
- Published `tipoff-web-mobile-polish-20261107-01`, frontend `20261107-21`: **4 files, 9 release assertions, 4 installed hashes, 6 browser/crawler preview checks passed**. No provider/runtime/cache changes. Live 319 px verified Today on its own line, four 28.8 px team marks, both accessible skull links, faint uppercase empty text, and no horizontal overflow. Screenshot `/tmp/tipoff-mobile-polish-live.jpg`. Actual Messages rendering remains untested.

## Logo-only matchups when names do not fit — November 7, 2026

- Shared per-row fitting measures full names, then shortened names, then hides visual text only when both logos are successfully loaded and shortened names still overflow. The logos keep their existing size and separator. Full names remain accessible and on hover; missing/loading/failed artwork retains text. Image load/failure, font loading, resizing, and hidden schedules opening recheck fitting. Source snapshots remain unchanged.
- **8 new sizing/resize/logo-fallback cases passed**, including wide/full, medium/short, narrow/logos, restoration, pending/failed/missing artwork. **82 existing web unit cases passed**: **90 unit cases total**. **16 route checks** and the existing collapsed-status markup check passed. JavaScript syntax and Git whitespace passed. **0 native app tests executed**.
- Local browser at **369 px** showed both Following rows as logo @ logo, with hidden text and full accessible team names; at **1261 px**, wider columns restored shortened names. Published `tipoff-web-compact-matchups-20261107-01`, frontend `20261107-20`: **3 files, 8 release assertions, 3 installed hashes, 6 browser/crawler preview checks passed**. Messages rendering remains untested. No provider/runtime/cache changes. Live 369 px verification showed both Following rows in logo-only mode with no horizontal overflow; wider live columns restored names. Screenshot `/tmp/tipoff-logo-only-matchups-live.jpg`.

## Status message alignment — November 7, 2026

- Removed the static summary label and vertically centered the remaining status text with equal padding and the existing 44 px target. Initial markup says “Loading schedules…”; completed messages and expanded source details remain unchanged. The disclosure stays collapsed by default.
- **7 existing summary cases, collapsed-default markup check, and 16 existing route checks passed**. No new unit tests; **0 native app tests executed**. Local geometry measured **13.74 px top / 13.75 px bottom** around the status text. Git whitespace passed.
- Published `tipoff-web-status-alignment-20261107-01`, frontend `20261107-19`: **2 files, 8 release assertions, 2 installed hashes, 6 browser/crawler preview checks passed**. Messages rendering remains untested. No JavaScript/provider/runtime/cache changes. Live panel stayed collapsed, displayed only “All schedules loaded Nov 7, 2026, 2:32 PM”, and retained equal top/bottom spacing. Screenshot `/tmp/tipoff-status-message-centered-live.jpg`.

## Schedule status summary refinement — November 7, 2026

- Kept the status disclosure collapsed by default. All successful results show “All schedules loaded” with the browser-local load completion timestamp. Saved results count as loaded; their original source timestamps, saved/fallback labels, and error descriptions remain in expanded rows. Partial/failed results show loaded/error counts and any pending loads.
- **7 new summary cases passed**, covering empty/partial loads, fresh/saved success, singular/multiple/all failures; collapsed-default markup check passed. **16 existing route checks passed**. JavaScript syntax and Git whitespace passed. **0 native app tests executed**.
- Published `tipoff-web-status-summary-20261107-01`, frontend `20261107-18`: **2 files, 8 release assertions, 2 installed hashes, 6 browser/crawler preview checks passed**. Actual Messages rendering remains untested. No provider/runtime/cache changes.
- Live browser confirmed the panel remained collapsed and read “All schedules loaded Nov 7, 2026, 2:26 PM”; all five expanded-row source strings retained their original 2:19 PM saved timestamps. Screenshot `/tmp/tipoff-collapsed-status-live.jpg`.

## Consolidated schedule status — November 7, 2026

- Moved source/freshness out of all card headers into a single initially closed disclosure below All Games, with loading/loaded, saved, and unavailable counts and five per-sport source/timestamp rows. Preserved saved timestamps, explicit fallback identities, and Altitude supplement warnings. Date changes reset loading states and aborted older requests cannot replace current results. Game-specific broadcast listings/notes remain in their disclosures.
- **75 existing web unit cases passed**, plus **16 existing local route checks**: **91 total**. JavaScript syntax and Git whitespace passed. **0 new unit tests / 0 native app tests executed** for this frontend presentation change.
- Published `tipoff-web-status-20261107-01`, frontend `20261107-17`: **3 files, 8 release assertions, 3 installed hashes**, and **6 browser/crawler metadata/image checks passed**. No source/runtime/cache/routing changes. Actual Messages rendering remains untested.
- Local panel expanded to five rows; live November 9 showed “5 loaded · 5 saved”, preserved the original timestamps and fallback identities, and kept card headers clear. All Games opened/closed with **0 card freshness nodes, 5 source rows, no horizontal overflow**. Screenshot `/tmp/tipoff-bottom-status-live.jpg`; guarded release rollback retained in the ignored publication workspace.

## Lime basketball favicon — November 7, 2026

- Added a self-contained SVG favicon embedding the supplied basketball PNG, preserving the header crop/transparency mask and setting explicit lime `#c8fa54`. Versioned `rel=icon` applies only to the guide; local preview serves the asset. The original brand PNG is unchanged.
- Published `tipoff-web-favicon-20261107-01`: **2 files, 5 HTTP assertions, 2 installed hashes passed**. **16 existing local route checks** and Git whitespace passed. **0 native app tests / 0 new web unit tests executed** for the favicon change. Six browser/crawler metadata/image checks passed with the existing social image unchanged; actual Messages rendering remains untested.
- Live browser confirmed the favicon declaration at `/tipoff` and rendered the asset visibly as the lime basketball with transparent seams. Screenshot `/tmp/tipoff-lime-favicon-live.jpg`; frozen payload and guarded rollback retained in the ignored publication workspace. Existing browser icon caches may require a refresh.

## Canonical URL rename — November 7, 2026

- Canonical `/tipoff` replaces `/tip-off` in HTML/Open Graph metadata, header and portfolio links, frontend assets/API, project registry, and sitemap policy. Local preview supports the new route and old aliases; cached clients retain both asset/API prefixes. Physical `tip-off.html` remains internal. No native providers, persisted data, runtime, or sibling project changes.
- **16 local HTTP route checks passed**, covering canonical metadata, query-preserving redirects, new/legacy assets and stubbed schedule endpoints, portfolio link, and unknown-route 404. **75 existing web cases passed** (17 artwork, 18 calendar grid, 20 date parsing, 10 broadcaster selection, 4 loading, 6 display names): **91 total**. JavaScript/Python syntax and Git whitespace checks passed. **0 native app tests executed** for this website-only change.
- Published `tipoff-web-url-20261107-01` with the normal unmodified publisher: **5 files**, **17 HTTP assertions**, installed-file verification, and PHP syntax validation passed. The protected Apache block was separately backed up, syntax-checked, and atomically installed with exact hash guards and original ownership/mode. An initial validation-command formatting error was corrected before installation; the initial Python-default-agent smoke request received the site's HTTP 403, while browser/crawler-agent checks passed without altering security rules.
- **6 direct redirect checks** confirmed HTTP 302 and query retention for legacy/slash routes. **14 browser/crawler metadata/image checks passed** across seven page routes; all identify `https://www.jimmyweber.com/tipoff`. Generated sitemap retains **407 URLs**, replacing only Tipoff's old URL. Existing 1920 × 1080 preview art remains unchanged; Messages rendering untested.
- Live browser: visiting `/tip-off` reached `/tipoff`, rendered both followed games, and loaded next-day NFL listings and the calendar. Screenshot and guarded two-stage rollback records remain in the ignored publication workspace. Restore the web release before routing on rollback.

## Dark-background team artwork — November 7, 2026

- ESPN’s public team metadata explicitly supplies rel=[full,dark] versions for **139 teams**: NBA 30, NFL 32, WNBA 15, NHL 32, MLB 30. Fetched and decoded **all 139 dark PNGs successfully** (HTTP 200/image assets). Reviewed default/dark comparisons for 12 representative marks on the guide’s actual surface and at row size, including Jazz, Jets, Rams, Giants, Lightning, Maple Leafs, Capitals, Rockies, Tigers, Yankees, Liberty, and Grizzlies. Some already suitable marks are unchanged; difficult marks gain the provider’s light artwork or outlines. Audit metadata, asset results, and comparison sheet remain in ignored `.build/team-logo-review`.
- Shared team rendering now prefers 500-dark artwork, preserves league aliases, and retries the default ESPN asset on failure. Numeric MLB IDs are matched using MLB’s [team metadata](https://statsapi.mlb.com/api/v1/teams?sportId=1) to ESPN’s [MLB team/logo metadata](https://site.api.espn.com/apis/site/v2/sports/baseball/mlb/teams?limit=100); the original MLB SVG is retained as a final fallback, including for unknown IDs. All-failed images are removed while names remain. No CSS recoloring, sizing, schedule-source, or persisted data changes.
- **17 new logo routing/fallback cases passed**, covering all five sports, league aliases, MLB numeric IDs, unknown IDs, unsafe input, fallback order/non-mutation, and original network-logo failure behavior. **58 existing web cases passed**: **75 web cases total**. JavaScript syntax and Git whitespace passed; **0 native app tests executed** for this frontend artwork change. All 139 dark image endpoints decoded separately from unit tests.
- Local November 17 showed loaded dark assets for all 10 visible NBA/NHL teams, with materially brighter Jazz, Capitals, Lightning, and Maple Leafs marks. Live November 17 and November 8 representative team artwork verified on the existing dark rows; names, network columns, and row sizes remain intact.
- Published `tipoff-web-dark-teams-20261107-01`: JavaScript/HTML only, frontend `20261107-15`. All **10 release assertions**, **2 installed hashes**, and **4 browser/crawler preview checks** passed. Native providers/cache/runtime and existing team/logo source identity fields are unchanged. Actual Messages rendering remains untested. Frozen payload, backups, rollback command, comparison audit, and screenshot evidence remain in ignored build workspaces.

## Date chevron removal — November 7, 2026

- Removed the date button’s decorative ::after arrow. Date text, previous/next day arrows, and calendar behavior remain intact. JavaScript syntax and Git whitespace checks passed; **0 app tests / 0 web unit tests executed** for this CSS-only removal.
- Published `tipoff-web-date-arrow-20261107-01`, CSS/HTML only, frontend `20261107-14`. All **10 release assertions**, **2 installed hashes**, and **4 browser/crawler preview checks** passed. Live date text had no ::after content and the calendar still opened/selected a day. Frozen release, backup/rollback records, and screenshot remain in the ignored deployment workspace.

## Site-themed calendar popover — November 7, 2026

- Replaced the browser-native date field/popup with an HTML popover using the guide’s solid surface, thin border, Roboto text, lime selected-day fill, lime today outline, and visible keyboard focus. Month arrows, six weeks of date cells, adjacent-month dates, and a Today shortcut are included. The panel anchors to the date button and clamps within the viewport; overflow scrolls on short screens.
- Grid keyboard controls: arrow keys by day/week, Home/End within a week, PageUp/PageDown by month, Shift+PageUp/PageDown by year, native button Enter/Space selection, and Escape dismissal with focus return. One day is tabbable; full date names and selected/current state are exposed. Click-away and trigger-toggle dismissal use the popover API. Responsive relocation explicitly closes it and synchronizes aria-expanded/focus.
- **18 new month/grid cases passed** across Denver/Auckland, covering six-week Sunday-first grids, unique local-noon days through DST/year/leap boundaries, and month-end clamping. **40 existing web cases passed** (20 date parsing, 10 broadcaster selection, 4 loading, 6 display names): **58 web cases total**. JavaScript syntax and Git whitespace passed. **0 native app tests executed**; providers/runtime/caches remain unchanged.
- Local browser: clicked November 17, navigated next/previous months without changing the selected guide day, used PageDown/PageUp and left/right followed by Enter, toggled the trigger closed, selected Today, and dismissed via Escape and a click outside. At 325 × 666 px the panel was **309.00 × 409.92 px**, x=8.00, y=133.62, with no horizontal overflow and one roving day tab stop. Computed surface **RGB(20,31,48)** and selected fill **RGB(200,250,84)** matched the site. At 1261 px it anchored under the header date button and fit inside the viewport. Resizing back to the main layout closed it, reset aria-expanded, and returned focus to date.
- Published `tipoff-web-themed-calendar-20261107-01`: HTML/CSS/JS only, frontend version `20261107-13`. Live calendar styling and selection verified. All **10 release assertions**, **3 installed hashes**, and **4 browser/crawler preview checks** passed. Existing header PNG, network artwork, schedules, and social metadata/artwork preserved. Actual Messages rendering remains untested. Frozen release, backup/rollback information, and screenshot remain in the ignored deployment workspace.

## Calendar picker, header mark, and NBCSN — November 7, 2026

- Made the displayed date a 44 px button opening the browser’s native date calendar. Picking a day updates the guide and restores focus to the button; Today/arrows keep the input synchronized. Accessible button labels include the full selected date. A visible native date field is provided when showPicker is unavailable. Selection parses components into local noon and rejects invalid/cleared dates, avoiding UTC day shifts.
- Added Jimmy’s supplied 232 × 230 PNG as `web/brand-mark.png`, served in production at `assets/img/projects/tipoff-header-mark.png`. The original bytes are retained. An inline SVG clips to the ball and uses its teal/gray separation as a mask, flooding with currentColor (#c8fa54); seams/background become transparent. No new gradients or changes to native app artwork. Preview routing serves the same asset locally.
- Added distinct NBCSN and NBC Sports Network aliases to the [current NBCSN SVG](https://commons.wikimedia.org/wiki/File:NBCSN_Logo_2025.svg), rendered white using the existing logo filter. Source returned HTTP 200/image/svg+xml and the browser loaded it for the NBA.com NBC Sports Network listing.
- **20 calendar cases passed** across America/Denver and Pacific/Auckland (local noon, DST boundaries, leap day, year boundary, malformed/invalid dates), plus **20 existing web cases** (4 loading, 10 broadcaster selections, 6 display names): **40 web cases total**. JavaScript syntax, Python preview syntax, and Git whitespace passed. **0 native app tests executed**; scheduling providers/cache/runtime are unchanged.
- Local browser: clicking the date opened the native calendar table; Down/Right/Right/Right/Enter selected November 17 from November 7 and updated the guide. Desktop calendar opened and Escape dismissed it without changing November 9. Moving controls between main and desktop header retained one selected date/picker. At 325 px the brand/header and date controls had no horizontal overflow; the back link wrapped onto two lines. The tint’s computed flood color matched RGB(200,250,84). Live calendar selection, tinted mark, NBCSN logo, and responsive layout verified. Only a popup-capable browser was exercised; the compatibility field remains untested manually.
- Published `tipoff-web-calendar-brand-20261107-01`: new header PNG plus HTML/CSS/JS, frontend version `20261107-12`. All **10 release assertions**, **4 installed hashes**, and **4 browser/crawler preview checks** passed. Header PNG checksum/MIME included in release verification; existing social artwork/metadata preserved. Actual Messages rendering remains untested. Frozen payload, backups, rollback command, and screenshots remain in the ignored deployment workspace.

## Horizontal inline logo groups — November 7, 2026

- Inline broadcaster groups now use nowrap with proportional flex shrink on their items/images. Multiple marks fit side by side in the existing fixed column; single marks retain the larger shared caps. The white NBC artwork, clean ESPN wordmark, 0.5 rem gaps, away-logo alignment, and expanded-list wrapping are preserved.
- Local November 10 checks covered 540 px and 325 px. ESPN+/Hulu/Disney+ remained on one line, with matching vertical centers within 0.01 px at 325 px; all five national matchups started at 103.62 px. No horizontal overflow. The single NBC mark retained its 23.72 × 22.39 px size at 540 px. Live November 10 horizontal grouping was verified.
- CSS/HTML-only release `tipoff-web-logo-row-20261107-01`, asset version `20261107-11`. JavaScript syntax and Git whitespace passed; **0 app tests and 0 web unit tests executed** for this CSS adjustment. All **9 release assertions**, **2 installed hashes**, and **4 browser/crawler preview checks** passed. Frozen payload, backup/rollback information, and screenshot remain in the ignored deployment workspace. Actual Messages rendering remains untested.

## Readable broadcaster logos — November 7, 2026

- Replaced black-letter horizontal NBC artwork with the colored-peacock/white-letter [NBC asset](https://commons.wikimedia.org/wiki/File:NBC_2023_white_logo.svg). Replaced ESPN’s padded red tile with its [clean vector wordmark](https://commons.wikimedia.org/wiki/File:ESPN_wordmark.svg), rendered white using the existing monochrome-logo class. Both SVG endpoints returned HTTP 200 and image/svg+xml and parsed successfully. Broadcaster names/text fallbacks remain intact.
- Removed the smaller inline-only size rule. All network marks now use the same proportional **3 rem width / 1.4 rem height caps**, preserving artwork shapes and the shared 0.5 rem gap. Groups wrap within the existing fixed column; matchups remain a single row and longer network groups can increase row height.
- Local November 10: NBC measured **23.72 × 22.39 px** (previous inline height cap 16 px and horizontal width cap 28.8 px). Peacock was **48 × 12 px**, ESPN+ **48 × 9.60 px**, Hulu **48 × 15.83 px**, Disney+ **41.22 × 22.40 px**, TNT **22.40 × 22.40 px**, and HBO Max **48 × 7.60 px**. All loaded. At 325 px, all five national matchup columns started at **103.62 px**, with no horizontal overflow; 1261 px desktop also had no overflow and aligned starts within each card. Live November 10 logo rendering and alignment checked; at 540 px all five national matchups began at 148.02 px. Live November 9 ESPN loaded as a 48 × 11.87 px clean white wordmark with ABC alongside it.
- **20 web regression cases passed** (10 broadcaster selections, 4 loading, 6 display names). JavaScript syntax and Git whitespace passed. **0 native app tests executed** for this frontend-only change. Published `tipoff-web-logo-scale-20261107-01`, HTML/CSS/JS, frontend version `20261107-10`. All **9 release assertions**, **3 installed hashes**, and **4 browser/crawler preview checks** passed. Native data, runtime, broadcaster classification, and source/cache freshness are unchanged. Actual Messages rendering remains untested. Frozen payload, backup/rollback records, and screenshots remain in the ignored deployment workspace.

## Adaptive team display names — November 7, 2026

- Shared matchup rendering now measures both full names, logos, separator, and gaps against the actual matchup column. Full names appear when both fit; otherwise both use the existing city/state-prefix removal. ResizeObserver handles container changes/hidden sections opening, font loading rechecks metrics, and day changes disconnect obsolete observations. Remaining very long nicknames retain existing inline ellipsis behavior. Full display names remain available on hover; snapshots are untouched.
- NBA.com cards can omit teamCity. Added an NBA-only display lookup verified against https://www.nba.com/teams on November 7, 2026, without overriding existing full or unknown names. The lookup does not affect broadcaster/source/cache fields.
- **6 display-name cases**, **10 compact Following cases**, and **4 client-loading cases passed** (**20 web tests**). JavaScript syntax and Git whitespace checks passed. **0 native app tests executed**; native providers/runtime/cache code was unchanged.
- Local November 8 desktop (1261 px) showed Denver Broncos @ Carolina Panthers in a **781.60 px** matchup column and full NFL names in national rows. At 540 px it switched to Broncos @ Panthers; at 325 px, expanded All Games also used shorter names without horizontal overflow. Resizing wide restored full NFL/NHL names. November 7 desktop All Games showed Denver Nuggets @ Indiana Pacers and full NBA/NHL names while smaller side-by-side Following cards independently kept shorter names.
- Published `tipoff-web-adaptive-names-20261107-02`, HTML/CSS/JS, frontend version `20261107-09`. Read-only preparation 01 was superseded to include NBA display expansion and was never published. All **9 release assertions**, **3 installed hashes**, and **4 browser/crawler preview checks** passed. Live desktop/narrow fitting verified. Actual Messages rendering remains untested; frozen payload, backup/rollback records, and screenshots remain in the ignored deployment workspace.

## Responsive date placement — November 7, 2026

- The single date-control group moves into a centered header slot at **64 rem / 1024 px** and wider, between the brand and back link. Below that breakpoint it stays in main above the section heading and spans the full content width. Header placement removes the redundant bottom rule; the body toolbar keeps its thin baseline. Date/listener state and keyboard focus are retained when moving the original node.
- Local desktop **1261 px**: one date group inside the header, 384 px wide, within its 60.83 px height; no horizontal overflow. After selecting November 8, resizing to **833 px** preserved that date and moved controls into main, with toolbar and section widths both **769.34 px**. At **325 px**, both widths were **297.01 px**, with no overflow. Focus remained on Next through relocation; keyboard Today restored November 7.
- **4 client-loading tests passed**, JavaScript syntax and Git whitespace passed. **0 native app tests executed** for this frontend layout change. Published `tipoff-web-responsive-date-20261107-01` with HTML/CSS/JS and asset version `20261107-08`. All **9 release assertions**, **3 installed hashes**, and **4 browser/crawler preview checks** passed. Live desktop/header and mobile/body placement verified; footer remains at the document bottom. Actual Messages rendering remains untested. Frozen release, backup/rollback information, and screenshots are in the ignored deployment workspace.

## Date toolbar refinement — November 7, 2026

- Removed the date component’s enclosing fill, border, and rounded frame. A thin bottom rule now anchors a 24 rem toolbar to the page; muted arrows have transparent borders/backgrounds and Today retains a subtle outline with neutral text. Hover/focus states and 44 px controls remain. Footer behavior is unchanged.
- Local checks covered **1261 px** desktop and **325 px** mobile. The group had transparent background and only a bottom border; no horizontal overflow at 325 px. Next-day mouse and Today keyboard activation passed. Live toolbar and footer checked. **0 app tests executed** for this CSS-only refinement; JavaScript syntax and Git whitespace passed.
- Published `tipoff-web-date-refinement-20261107-01`, CSS/HTML only, frontend version `20261107-07`. All **9 deployment assertions**, **2 installed hashes**, and **4 browser/crawler preview checks** passed. Rollback records and screenshots remain in the ignored deployment workspace. Actual Messages rendering was not tested.

## Date component and bottom footer — November 7, 2026

- Grouped date navigation in a solid, bordered container. Previous/next and Today have visible button borders/backgrounds, 44 px minimum targets, existing keyboard focus styling, and lime Today text. Date updates and calendar-day behavior are unchanged.
- The page uses a minimum viewport-height flex column with a growing main area; header/footer do not shrink. The footer remains in document flow. Local short-page footer bottom **745.00 px** matched the **745 px** viewport. With All Games expanded, main bottom and footer top matched at **1985.03 px**; footer bottom **2045.86 px** matched document height **2046 px**. No footer overlap or trailing gap. At 325 px the date component fit without horizontal overflow; its long Today label wrapped within the date cell.
- Local next-day/Today interactions and live date controls/footer were checked. CSS/HTML-only release `tipoff-web-navigation-20261107-01`, asset version `20261107-06`. All **9 deployment assertions**, **2 installed hashes**, and **4 browser/crawler preview checks** passed. JavaScript syntax and Git whitespace checks passed; **0 app tests executed**. Schedule providers/runtime/caches unchanged. Actual Messages rendering remains untested. Frozen payload, backups, rollback command, and screenshots remain in the ignored deployment workspace.

## Shared header separator — November 7, 2026

- Added a faint one-pixel inset bottom stroke to the shared league/card header, using muted text color at 16% opacity. Applies to Following, National Broadcasts, and All Games without changing header height or row alignment. Flat fills and the rollback switch remain intact.
- Local and live November 8 browser checks confirmed the separator below the Broncos and NFL headers; computed style was `rgba(174, 187, 208, 0.16) 0px -1px 0px 0px inset`. JavaScript syntax and Git whitespace checks passed. **0 app tests executed** for this CSS-only adjustment.
- Published `tipoff-web-divider-20261107-01`: CSS and HTML asset version `20261107-05`. All **9 release assertions**, **2 installed hashes**, and **4 browser/crawler link-preview checks** passed. Backups and guarded rollback are retained in the ignored deployment workspace. Actual Messages rendering remains untested.

## Compact Following broadcast rows — November 7, 2026

- Following rows now share the national layout: fixed broadcaster column, short matchup, and start time. Source-listed national networks take priority; otherwise the compact row uses a listed Altitude / Altitude 2 network (preferring the matched Altitude guide), or the first listed video broadcaster. No rights or streaming availability is inferred. Full-schedule behavior is retained.
- One disclosure reveals all original video listings and regional labels, plus Altitude networks, pre/postgame times, footnotes, and original freshness. Simple national-only rows need no disclosure. Footnoted network names retain their labels while using the corresponding brand mark.
- **10 compact-selection cases passed**, including national priority, Altitude 2, NHL ALT, footnotes, composite names, unknown networks, empty/radio-only inventories, and unchanged input data. **4 existing client-loading tests passed**. JavaScript syntax and Git whitespace checks passed. **0 native app tests executed** for this frontend-only change; providers, models, caches, and runtime were unchanged.
- Local browser checks covered November 7 Altitude 2 / Avalanche, November 8 Broncos (no empty disclosure), and November 9 Nuggets. Mouse expansion and keyboard collapse passed; all Altitude notes/show times remained available. At 325 px there was no horizontal overflow. On production November 9, Following and national matchup columns all began at **109.55 px** in the 498 px view. Expanded live data retained ALT2/KTVD, KUSA-TV (9NEWS), KTVD-20^, the regional footnote, show times, and the original 9:35 AM Altitude timestamp.
- Published `tipoff-web-following-20261107-01`: only guide CSS, JavaScript, and HTML, asset version `20261107-04`. All **9 deployment assertions**, **3 installed hashes**, and **4 canonical/alias browser/crawler link-preview checks** passed. Actual Messages rendering was not tested. Frozen payload, backup/rollback information, and screenshot evidence are in the ignored deployment workspace.

## Inline header game counts — November 7, 2026

- Grouped the shared header name and game count with baseline alignment, keeping the optional National marker on that same line. Source/freshness remains right-aligned and may wrap below the intact left group on narrow screens. Applies to Following, National Broadcasts, and All Games; flat-mode rollback remains intact.
- Local November 8 Broncos text bounds matched exactly for National and 1 GAME: top **204.21 px**, bottom **216.29 px** at 498 px. At 325 px the group used baseline alignment and had no horizontal overflow.
- Published `tipoff-web-headers-20261107-01`: HTML/CSS/JS, asset version `20261107-03`. All **9 deployment assertions** and **3 installed hashes** passed. JavaScript syntax and Git whitespace checks passed. **0 app tests executed** for this header-layout-only change. Live text bounds matched the local baseline measurements. Canonical/alias browser/crawler preview checks passed (**4 page/image checks**).

## Reversible flat-surface pass — November 7, 2026

- Audit found no authored CSS gradient functions. Applied a scoped flat-surface treatment: uniform card/header fills, no alternating row shading, and muted text instead of whole-row brightness filters for collapsed games/empty leagues. Original styles remain behind the `tipoff-flat` body switch.
- Tested rollback locally: removing the body class restored the prior header RGB(28,42,64); re-enabling it restored RGB(20,31,48). All 17 measured collapsed game rows had the flat fill and filter=none. At 325 px there was no horizontal overflow.
- Published `tipoff-web-flat-20261107-01`, HTML/CSS only. All **9 HTTP assertions** and **2 installed hashes** passed. Live November 8 national headers and rows shared RGB(20,31,48), with background-image=none. The previous HTML/CSS backup and rollback command are retained in the isolated deployment workspace.
- JavaScript syntax and Git whitespace checks passed. **0 app tests executed** for the CSS/markup-only pass. Canonical/alias preview checks passed for browser and crawler agents (**4 page/image checks**). Schedule data and source behavior are unchanged.

## Section headings below date navigation — November 7, 2026

- Moved the conditional Following / National Broadcasts heading out of the date-controls wrapper into the page body immediately below the selector, at every viewport width. Existing conditional heading behavior and schedule loading are unchanged.
- Local browser geometry at 498 px showed the date selector ending at y=125.62 px, the section heading starting at y=141.62 px, and followed cards starting below it. The 325 px view retained the order without horizontal overflow. Live November 8 showed the same order above the Broncos card.
- Published `tipoff-web-20261107-01`, replacing only guide HTML and CSS with asset version `20261107-01`. All **9 deployment assertions** and **2 installed checksums** passed. JavaScript syntax and Git whitespace checks passed. **0 app tests executed** for this layout-only change. Canonical/alias preview verification passed for browser and crawler agents (**4 page/image checks**).

## Live schedule loading repair — November 6, 2026

- Root cause: the old PHP endpoint held each HTTP request while an NBA refresh ran, sharing one lock across every date in that sport. Slow refreshes caused 20-second lock waits and up to 85-second process waits, even when working saved schedules existed.
- Added read-only `TipoffCheck --web-cached`, returning the same typed, ISO 8601, display-ordered model without any networking or cache writes. Production now returns saved schedules immediately, retaining source and freshness, and refreshes in detached bounded jobs with per-sport/date/zone locks. Cold caches return 202; failed attempts back off; client polling has abort and timeout bounds. Followed results render before all league requests finish. The local Python preview still uses the original `--web` path.
- `scripts/test.sh`: **57 tests passed**, including the four-case parameterized test (**60 individual test/case executions**). `scripts/package-app.sh .build/loading-package` built and signed the app successfully. Live `.build/debug/TipoffCheck 2026-11-06 --nhl`: **NHL.com, 3 games**.
- `python3 Tests/Web/cache-only-test.py .build/debug/TipoffCheck`: **7 executed, 7 passed** (fresh/stale/missing/malformed cache, identity isolation, telemetry exclusion, invalid dates, original bytes/freshness).
- Final PHP fixture run under PHP 8.4: **9 executed, 9 passed**, covering fresh/stale data, busy-lock latency, cold pending-to-ready, wrong day/zone, malformed data, failure backoff, and independent date locks. An earlier eight-case smoke run also passed. Both deployed PHP files linted with production PHP 8.1.
- `node Tests/Web/fetch-schedule-test.cjs`: **4 executed, 4 passed**, covering immediate cache responses, 202 polling, date-change cancellation, and bounded pending time. JavaScript syntax and Git whitespace checks passed.
- Linux amd64 executable built in `swift:6.3-jammy`, stripped, dependency-checked, and validated as www-data against the real saved November 7 NBA cache (**7 games**) before atomic replacement. Previous executable retained with rollback hash guard; persisted caches were not replaced.
- Published `tipoff-web-loading-20261106-01`: new schedule helper PHP, endpoint PHP, guide JS, and HTML. All **9 HTTP assertions** and **4 installed checksums** passed. Six concurrent live endpoint checks returned in **0.284–0.993 seconds** across NBA/NHL/NFL dates, with 200 for available saved schedules and 202 for two cold NBA dates. All identity checks passed.
- Live browser verified November 7 Nuggets/Avalanche listings and November 8 Broncos/national listings during background refreshes, without the old cross-date wait. Saved listings showed their original timestamps. No source or cache schema changed.

## Consistent icon spacing — November 6, 2026

- Replaced fixed-width logo image slots with proportional boxes and a shared 0.5 rem gap across network groups, regional labels, and team-logo/name pairs. Natural image ratios are applied after load, including percentage-sized SVGs. National rows retain the fixed-width network column and aligned away logos.
- Local browser measurements confirmed 8 px gaps for normal and inline broadcaster groups on November 7 and 10. All five national away logos retained the same x=148.02 px position at 540 px. All logo boxes had nonzero dimensions; the 325 px view had no horizontal overflow.
- Published `tipoff-web-20261106-05`: CSS, JavaScript, and HTML. All **8 deployment HTTP assertions**, **3 installed file checksums**, and **4 browser/crawler page/image preview checks** passed. Preparation 04 was superseded locally without publication.
- JavaScript syntax and Git whitespace checks passed. **0 app tests executed**; frontend presentation change with unchanged source providers and caches.

## Altitude 2, Altitude+, and NBA TV logos — November 6, 2026

- Added distinct Altitude 2 / ALT2, Altitude+, and NBA TV logos. Kept accessible broadcaster names and text fallback. Altitude 2 renders white; Altitude+ uses its official white mark; NBA TV retains its colors and remains excluded from national highlights.
- Both PNGs and the NBA TV SVG returned HTTP 200 with the expected MIME types; PNG alpha checks confirmed transparency. Local and live November 7 Nuggets listings loaded all three marks successfully.
- Published `tipoff-web-20261106-03`: only JavaScript and HTML changed; CSS was unchanged and omitted. All **8 deployment HTTP assertions** and **2 installed-file checksums** passed. Link-preview checks passed for canonical and alias URLs with browser/crawler agents (**4 page/image checks**).
- JavaScript syntax and Git whitespace checks passed. **0 app tests executed**; logo-only frontend change. Backend, source data, caches, and routing were unchanged. Asset provenance is in the website handoff.

## Approved web redesign deployment — November 6, 2026

- Published `tipoff-web-20261106-02`: only guide HTML, CSS, and JavaScript. Versioned CSS/JS URLs avoid stale frontend assets. The staged files were formatted with Prettier 3.6.2. No backend, runtime, cache, route, or sitemap changes.
- All **8 deployment HTTP assertions** and **3 installed file checksums** passed, including canonical/alias/slash routes, exact CSS/JS hashes, portfolio link, and a schedule endpoint. A separate deployment verify run passed again.
- Link-preview checks: **8 page/image checks passed** (four routes × browser/Facebook crawler agents), including canonical metadata and decoded 1920 × 1080 PNG. Messages client rendering remains untested.
- Five live league endpoints returned valid November 6 America/Denver snapshots: NBA **9** via labeled ESPN fallback, NFL **0**, WNBA **0**, NHL **3**, MLB **0**. The first concurrent NBA check returned HTTP 503; retry returned HTTP 200 with nine fallback games. The backend was unchanged.
- Live browser checks covered default collapsed All Games, expansion, NBA/NHL filters, short team names, fallback source/freshness, Next/Today controls, and keyboard collapse. At 325 px content width, the page had no horizontal overflow.
- JavaScript syntax and Git whitespace checks passed. **0 native app tests executed** for this frontend deployment; the previously recorded 34 short-name and 10 classification checks apply to unchanged JavaScript behavior. Frozen release/backup/rollback details are retained in the ignored isolated deployment workspace.

## Consistent national network column — November 6, 2026

- National rows reserve the same network column width regardless of the number of broadcasters, centering icons within it and aligning all away-team logos. The column uses 6.5 rem normally and 4.2 rem on narrow screens, with icon wrapping inside the reserved space.
- Browser verified November 10 and 11 rows with one, two, and three networks. At 540 px, all measured national away logos began at x=148.02 px with a 104 px network column. At the narrow 325 px content viewport, all four November 11 away logos began at x=103.62 px with no horizontal overflow.
- `node --check web/guide.js` and `git diff --check` passed. **0 app tests executed**; CSS-only behavior change. Local preview updated; not deployed.

## Short team names across sports — November 6, 2026

- The shared web team renderer removes recognized location prefixes, keeping team names such as Celtics, 76ers, Red Wings, Blues, Trail Blazers, and White Sox. Applies to Following, National Broadcasts, and All Games for all five sports. Source names remain in hover titles; provider output and cached snapshots are unchanged. Unknown names remain unchanged.
- **34 JavaScript short-name checks executed, 34 passed**, spanning NBA, NFL, WNBA, NHL, MLB, multiword names, bare names, unknown names, and a location-only input. `node --check web/guide.js` and `git diff --check` passed. **0 native app tests executed**; presentation-only change.
- Verified the November 10 local view shows Red Wings @ Blues, Panthers @ Blue Jackets, Predators @ Kings, and Celtics @ 76ers. Confirmed short names also appear in the expanded full schedule and original names remain in hover titles. Local preview updated; not deployed.

## Inline national broadcaster logos — November 6, 2026

- National broadcaster logos now precede the matchup with the start time on the right, using the shared row renderer across highlights and All Games. Other broadcasters remain below. National names are deduplicated against the remaining listings, radio stays hidden, and regional/Altitude details remain intact.
- National matchups stay on one line; long names use an ellipsis while preserving full accessible text and hover titles. On narrow screens the logo group can wrap within its column.
- Browser verified November 10: all five national NBA/NHL rows had a single 22.4 px matchup line and approximately 44.8 px row height at a 540 px content viewport. The regional Avalanche listing retained its broadcaster below. No horizontal overflow at 540 px or 325 px.
- `node --check web/guide.js` and `git diff --check` passed. **0 app tests executed**; frontend layout change with unchanged source providers and caches. Local preview updated; not deployed.

## TNT, HBO Max, Altitude, and truTV logos — November 6, 2026

- Added the four requested broadcaster marks. Altitude and ALT map to the same logo; Altitude 2 and Altitude+ keep their distinct text. All four render white on the dark background and retain existing accessible source names, text fallback, and regional tags.
- All four SVG URLs returned HTTP 200 with image/svg+xml. Browser checks confirmed loaded Altitude / ALT on the November 10 Avalanche listing, TNT and HBO Max on November 10 NHL listings, and truTV on November 11 NHL listings. Visually inspected all four marks in the local browser.
- `node --check web/guide.js` and `git diff --check` passed. **0 app tests executed**; logo-only frontend change. No schedule or cache changes. Local preview updated; not deployed. Asset provenance is recorded in the website handoff.

## Peacock / FOX logos and NFL Network exclusion — November 6, 2026

- Added Wikimedia Commons Peacock and FOX wordmarks using the existing accessible-name and text-fallback behavior, with white rendering for the dark background. Both SVG URLs returned HTTP 200 with image/svg+xml; browser checks confirmed successful image loads.
- Excluded normalized NFL Net, NFL Network, and NFLN listings from national highlights. November 8 showed 11 other national NFL games, with Bengals–Falcons absent from the summary and retained in All Games with expandable NFL Net details. FOX logos loaded on Sunday listings. November 9 Wizards–Pistons displayed the Peacock logo.
- **10 JavaScript classification checks executed, 10 passed**: three NFL Network aliases, FOX, Peacock, CBS, NBA TV, NHL Network, League Pass, and regional FOX. `node --check web/guide.js` and `git diff --check` passed. **0 native app tests executed**; frontend-only change, no provider or cache changes. Local preview updated; not deployed.

## Conditional landing heading — November 6, 2026

- Following appears as the top heading only when followed games are listed. Otherwise National Broadcasts occupies that row beside the date controls, without a duplicate heading or empty Following section. Followed schedule errors remain visible independently of the heading.
- Verified November 6 shows National Broadcasts, two NBA games, and no Following heading or duplicate national heading. Next-day navigation showed Following with Nuggets and Avalanche on November 7, followed by the separate National Broadcasts section. Today restored the national-only heading. At 599 px the heading and date controls stayed inline without horizontal overflow.
- `node --check web/guide.js` and `git diff --check` passed. **0 app tests executed**; frontend-only change. Local preview updated; not deployed.

## Inline date navigation — November 6, 2026

- Moved the existing date controls beside Following, with wrapping below the heading on narrow screens. The heading and controls remain available on empty days; no empty-team message was added. Time zone and league filters remain inside All Games.
- Verified November 6 to November 7 navigation with All Games closed. Nuggets and Avalanche listings appeared for November 7. Verified inline placement at 599 px and no horizontal overflow at 599 px or the narrow 325 px content viewport.
- `node --check web/guide.js` and `git diff --check` passed. **0 app tests executed**; frontend-only change. Local preview updated; not deployed.

## Shared browser card headers — November 6, 2026

- Following, National Broadcasts, and All Games now use the same header builder and CSS. Summary counts reflect only their displayed games. Source and freshness move into the approved right-aligned header layout; the accent, typography, padding, and background match All Games.
- Browser verification confirmed identical computed font, padding, left border, and background for the national NBA and All Games NBA headers. November 6 showed 2 national NBA games and 9 total NBA games. November 5 showed Avalanche with a National marker, 1 game, and source/freshness in its header. Today restored the correct national count and hidden empty Following section.
- `node --check web/guide.js` and `git diff --check` passed. **0 app tests executed**; frontend-only change. Local preview updated; not deployed.

## Reduced landing controls — November 6, 2026

- Removed the visible page title and subtitle. Moved date navigation and the time zone into All Games. Following is hidden when there are no games, while schedule failures still receive a visible status.
- Verified the local November 6 landing view starts with National Broadcasts, with date controls and empty Following hidden. Expanded All Games exposes the date controls, time zone, filters, and full schedule. Previous-day navigation showed the November 5 Avalanche listing; Today restored the empty Following state. Space collapsed All Games. No horizontal overflow at the tested 599 px content viewport.
- `node --check web/guide.js` and `git diff --check` passed. **0 app tests executed**; frontend-only change. Not deployed.

## Simplified browser landing view — November 6, 2026

- Local frontend change only; not deployed. Following and National Broadcasts appear on arrival; All Games and its league filters start collapsed. Kept the current four followed teams.
- Verified with live local schedules for November 6 and November 5 in America/Denver. Today showed two national NBA games and no followed games. November 5 showed Avalanche once in the highlights with its National marker, alongside the other NFL/NHL national games. Sources and freshness remained visible.
- Mouse expansion and Space collapse worked. Selecting NHL filtered only All Games while retaining cross-league highlights. Previous-day and Today controls refreshed both views. No horizontal overflow in the tested browser at 528 px or the narrow 300 px content viewport, with All Games both collapsed and expanded.
- Local page returned HTTP 200. `node --check web/guide.js` and `git diff --check` passed. Preview built TipoffCheck successfully and used the unchanged live provider. **0 app tests executed**; no native or schedule-source code changed. Production and Messages checks were not repeated for this local preview.

## Production web deployment

- `scripts/test.sh` passed **57 of 57 tests**. `scripts/package-app.sh` built and verified the macOS app. A live macOS `TipoffCheck` returned 11 NHL games for November 5 in America/Denver.
- Built the x86-64 Linux executable in the Swift Jammy container and verified it on the production host as the web user. Live November 5 results through the public endpoint were NBA 2, NFL 1, WNBA 0, NHL 11, and MLB 0. The production origin received NBA HTTP 403 and MLB HTTP 406. Both guides showed ESPN fallback.
- Release `tipoff-web-20261105-01` passed all eight configured HTTP checks. The public alias and trailing slash routes reached the canonical URL, the endpoint rejected an invalid date with HTTP 400, and a preview crawler fetched the metadata and 1920 × 1080 image. The live browser showed Jaguars @ Ravens once on the NFL tab without horizontal overflow. Messages rendering remains untested.

## Roboto typography

- Verified the compact uppercase return links, subtitle, time zone label, and source label at 664 px in the local browser. The update time remains on its own line and the page had no horizontal overflow. JavaScript syntax and Git whitespace checks passed. **0 app tests executed**.

- Verified the font stylesheet includes Roboto weights 400–800. Browser computed styles showed Roboto for the intro, back link, freshness, broadcast list, and team names. Git whitespace checks passed. **0 app tests executed**.

## Teams Followed

- Verified the November 5 local browser view. Predators–Avalanche appeared in both summaries and had a blue outline in the full schedule. The two other national games retained lime outlines. Neither summary had outlined game rows. JavaScript syntax and Git whitespace checks passed. **0 app tests executed**.

## Single listings on league tabs

- Verified in the local browser that the NFL tab shows Jaguars @ Ravens once with its national outline. The NHL tab keeps the followed-game outline in the league schedule, and All restores the cross-sport summary. JavaScript syntax and Git whitespace checks passed. **0 app tests executed**.

## League filters and highlights

- Verified in the local browser that WNBA hides Avalanche and NFL highlights, NHL restores the Avalanche without NFL, and All restores the cross-league summary. JavaScript syntax and Git whitespace checks passed. **0 app tests executed**.

## Schedule controls

- Verified that the date controls and filters appear above the summaries, all five ESPN CDN league logos load, and the filter buttons have no borders. The NHL filter and date navigation responded in the local browser. JavaScript syntax and Git whitespace checks passed. **0 app tests executed**.

## Web TV and streaming listings

- Verified that NHL.com marks NHLN as National for Sharks @ Wild on November 6. The web guide now keeps the listing in the expandable full schedule without highlighting the game. Verified that Prime Video games remain highlighted and radio labels are absent. JavaScript syntax and Git whitespace checks passed. **0 app tests executed**.

## Compact headers and deduplicated broadcasts

- Verified in the local browser that Predators @ Avalanche appears only under the followed summary, with a National marker. The NBA header shows the game count beside the name and right-aligned source and freshness. JavaScript syntax and Git whitespace checks passed. **0 app tests executed**.

## Inactive leagues

- Verified the local November 5 view with NBA, NFL, and NHL above the collapsed WNBA and MLB sections. MLB opened on click and collapsed on Space, returning to 50% brightness. JavaScript syntax and Git whitespace checks passed. **0 app tests executed**.

## Compact broadcast listings

- Verified in the local browser that Utah @ Montréal starts at 50% brightness, returns to full brightness on click, and dims again when collapsed with Space. Git whitespace checks passed. **0 app tests executed**.

- Verified the combined heading and thin divider in the local browser. Boston @ Pittsburgh started collapsed, expanded on click, and collapsed on Space. Both summaries retained visible broadcasters. JavaScript syntax and Git whitespace checks passed. **0 app tests executed**.

## Responsive matchup wrapping

- Verified Predators @ Avalanche at 634px and 320px in the local browser. Both names fit on one line at 634px and wrap without clipping or page overflow at 320px. JavaScript syntax and Git whitespace checks passed. **0 app tests executed**.

## Single-line matchups

- Verified horizontal alignment of both teams, the separator, and the start time on 13 rendered rows across the national summary and full schedule. JavaScript syntax and Git whitespace checks passed. **0 app tests executed**.

## Game row fills and logo outlines

- Verified in the local browser that all broadcaster entries, including regional text labels, render without strokes. Full-schedule lime highlights remain visible. **0 app tests executed**.

- Verified in the local browser that loaded broadcaster logos have no visible outline, adjacent NBA rows alternate fills without divider strokes, and qualifying games retain their lime outline in the full schedule. Git whitespace checks passed. **0 app tests executed**.

## Dark broadcaster logos

- Verified Prime Video, ESPN+, Hulu, and Disney+ in the local browser. All four loaded on transparent backgrounds and retained their names in visually hidden text. JavaScript syntax and Git whitespace checks passed. **0 app tests executed**.

## National broadcast section

- Verified the border refinement in the local browser. All three summary rows had standard dividers, and the corresponding three rows in the full schedule retained their lime outlines. JavaScript syntax and Git whitespace checks passed. **0 app tests executed**.

- Verified November 5 in the local browser. The summary showed NFL (one game) and NHL (two games), with the same three games outlined below. The NHL feed categorized Anaheim–Edmonton’s Prime Video listing as Away TV. Utah–Montréal, NBA TV, and the other regional listings stayed out of the summary.
- Verified no horizontal overflow at the narrow browser width, previous-day and Today navigation, and that the NBA filter applies to the lower schedule only. JavaScript syntax and Git whitespace checks passed. Frontend-only change. **0 app tests executed**.

## Browser branding and homepage links

- Verified both homepage links in the local browser and inspected the narrow layout without horizontal overflow. The Magic, Suns, Jaguars, and Ravens marks loaded, as did the Prime Video logo. The visible station names and distinct Radio, Regional, and League Pass labels matched the live feed.
- All seven curated network image URLs returned HTTP 200 with image content types. JavaScript syntax and Git whitespace checks passed. Frontend-only change. **0 app tests executed**.

## Local browser guide — November 5, 2026

- `scripts/test.sh`: **57 tests executed, 57 passed**. `scripts/package-app.sh` built and verified the signed macOS app in a temporary directory.
- Live `TipoffCheck` for November 5, 2026 in America/Denver loaded NBA (2), NFL (1), WNBA (0), NHL (11), and MLB (0). The local page displayed all five results, including valid empty leagues and the Avalanche first in NHL.
- Local browser checks covered the `/sports` redirect, default All view, keyboard league filtering, previous-day navigation, and the portfolio preview link round trip. Verified layouts at 390 and 1280 pixels without horizontal overflow. Initial HTML included canonical and preview metadata. The existing banner decoded as a 1920 × 1080 PNG when fetched with a preview crawler user agent. Production guide routes and actual Messages rendering were outside this local check.

## Website preparation — November 5, 2026

- Reviewed Agentic Toolkit publishing, layout, and link preview guidance and the website’s existing deployment and project notes. The public homepage and Tipoff portfolio page returned HTTP 200. The proposed `/sports` and `/tip-off` paths returned HTTP 404.
- Documentation-only change. **0 app tests executed**. Checked Markdown references and diff whitespace.

## GitHub platform documentation — November 1, 2026

- Reviewed repository metadata, published releases, README, project instructions, plan, and data/source documentation against the Windows installer, packaging script, and WPF project. Updated the README's title, platform table, shared feature wording, build headings, and local-data paths; project instructions now identify both native apps and the computer's time zone.
- Updated GitHub's About description and topics to include Windows and its system-tray app. Added a current-platform notice to the existing release page and labeled its title macOS / NBA-only; preserved the original build notes and assets. No new binary release was created.
- Documentation-only change: **0 app tests executed**. Local Markdown file/anchor checks, diff whitespace checks, and read-back of GitHub metadata/release notes passed. Application builds and live-source checks were not needed; runtime, networking, and packaging code are unchanged. The pre-existing untracked `img/Tipoff-banner.png` is excluded.

## Inline Windows Altitude Details — October 24, 2026

- Moved the Details toggle beneath the time in the existing middle column, removing the separate expander-header row and its empty full-width strip. The full-width detail content is collapsed until the inline toggle is checked. Existing labels, source networks, show times, notes, and freshness bindings remain intact; games without Altitude details keep their compact layout.
- Windows fixture runner: **29 tests executed, 29 passed**. `scripts/package-windows.ps1` and `scripts/install-windows.ps1 -NoLaunch`: **passed**. No new automated tests added for this XAML-only layout change.
- Used Windows computer-use tools to inspect the installed dark-mode guide for October 24 and the user's October 26 example. The October 26 Warriors / Nuggets row now fits the toggle beside the broadcasters with no separate bottom strip. Clicked Details to reveal full-width networks, times, and freshness; pressed Space to collapse it and verified the compact row returned. October 24's Details* label remains intact. Reopened the installed app normally after inspection.
- No model, cache, source, or networking changes; no live-source check needed. macOS scripts require unavailable macOS/SwiftUI tooling and were not run on this Windows host. README, plan, and diff/content checks updated; unrelated shell-script line-ending changes and the untracked banner remain untouched.

## Compact Windows header and Light / Dark appearance — October 24, 2026

- Reduced the guide header from 58 to 36 logical units, with an 18-unit logo, 13-point title, and vector gear icon in a borderless 28×28 target. Gear retains the Settings tooltip and accessible name.
- Added Light and Dark appearance options in Settings, immediate dynamic-resource updates, and current-user persistence in `HKCU\Software\Tipoff\Appearance`. Missing/invalid preferences use Light; save failures show an inline error. Read failures preserve the default and surface a warning. No automatic OS-theme matching is claimed.
- Compared native macOS SwiftUI semantic colors with `docs/current-preview.png` and sampled its actual pixels: dark window `#1E1E1E`, cards `#252525`, primary text `#F4F4F4`, secondary text `#A5A5A5`, bright mint text `#40F3DF`, and selected-tab fill `#70DDCE`. Native Windows title bars and tray menus retain OS styling. Light preserves the established high-contrast teal palette.
- Windows fixture runner: **29 tests executed, 29 passed**. Release WPF build passed with **0 warnings, 0 errors**. Final `scripts/package-windows.ps1` and current-user `scripts/install-windows.ps1 -NoLaunch` both passed. No new automated tests added for appearance-only changes; runtime UI and persistence checks exercise the production implementation.
- Used Windows computer-use tools to open the gear, switch Light → Dark → Light, and inspect both Settings and the guide. Restarted the installed app with Dark saved and verified the dark palette restored. Corrected a selected-tab contrast issue found during inspection. Verified expanded Altitude text, regional notes, freshness, and the themed scrollbar; scrolling reached the remaining games. Both modes fit the existing 360-unit guide. Reopened the installed app normally with Dark selected after inspection.
- No schedule/source/network/cache changes. macOS `scripts/test.sh` and `scripts/package-app.sh` require unavailable macOS/SwiftUI tooling and were not run here; no live-source check needed. Unrelated shell-script line-ending changes and the untracked banner remain outside this change.

## Windows borderless date arrows — October 24, 2026

- Matched the macOS `chevron.left` / `chevron.right` plain-button treatment with WPF vector paths and invisible 28×28 rectangular click targets. Removed text glyphs and visible fills/borders, including hover/press boxes. Hover and keyboard focus tint the icon; press feedback changes opacity. Previous/next tooltips and explicit accessible names are preserved.
- Windows fixture runner: **29 tests executed, 29 passed**. `scripts/package-windows.ps1`: **passed** after closing a development copy that locked the initial publish output. `scripts/install-windows.ps1 -NoLaunch`: **passed**, updating the stable current-user installation and Start Menu shortcut.
- Used Windows computer-use tools to inspect the installed app in inspection mode: both vector chevrons render without boxes. Clicking the invisible padding outside the left chevron moved October 24 to October 23; clicking Next day returned to October 24. The 360-unit guide and date/footer layout remain intact. No new automated tests added for this view-only styling change.
- No networking, schedule, or cache changes; no live-source check needed. macOS scripts were not run because macOS/SwiftUI tooling is unavailable on this Windows host. Reopened the installed app in normal tray mode after inspection.

## Windows Settings and startup repair — October 24, 2026

- Added a Settings button to the guide header and Settings / About Tipoff to the tray menu. Inspected the installed WPF screen using Windows computer-use tools: the 360-unit window fits the startup toggle, notification-area explanation, registration status, Windows Startup Apps shortcut, version 0.4.1, and personal-tool/MIT About text without clipping. Opened Settings through the guide's button.
- Startup status now compares the Run command with the current executable rather than accepting any nonempty Tipoff entry. The tray checkbox refreshes when opened. Startup read/write failures remain visible; Settings shows inline errors.
- Windows fixture runner: **29 tests executed, 29 passed**. `scripts/package-windows.ps1`: **passed** after correcting a compile-time WPF/WinForms `Color` ambiguity. `scripts/install-windows.ps1`: **passed** at the default current-user location, including Start Menu shortcut creation and app launch. Replaced the running temporary `dist/windows-install-smoke` copy with `%LOCALAPPDATA%\Programs\Tipoff\Tipoff.exe`.
- Exercised the actual Settings checkbox off and back on. Verified off removes the Run entry and stores preference 0; on stores preference 1 and the exact quoted installed-executable command with `--startup`. Left startup enabled. Restarted the installed executable with `--startup`; it remained responsive with no visible main window. Registration and this launch check are not proof of a successful boot/sign-in.
- No schedule, source, networking, or cache changes. macOS `scripts/test.sh` and `scripts/package-app.sh` require unavailable macOS/SwiftUI tooling and were not run on this Windows host; no live-source check was needed. A real Windows sign-out/sign-in remains a hands-on check.

## Agent-ready Windows installation — October 23, 2026

- Added `scripts/install-windows.ps1` as the canonical current-user install path. It checks for the .NET 9 SDK, rejects a filesystem-root target, stops an existing copy from the exact target path, packages the current x64 app, creates a Start Menu shortcut, and launches Tipoff so its Start with Windows registration records the stable installed executable.
- Added a concise `CLAUDE.md` that routes Claude to `AGENTS.md` and the installer without duplicating product rules. README now separates current Windows source installation from the older downloadable macOS `v0.2.0` release and includes a copyable agent instruction.
- Verified through GitHub CLI that `v0.2.0` remains the only and latest published release; it is correctly described as the older macOS NBA-only build. No Windows binary release or conventional signed installer is claimed.
- Windows fixture runner: **29 tests executed, 29 passed**. Ran the installer against isolated ignored paths with launch disabled; packaging and WPF compilation passed, the seven expected application/license files were present, and the generated Start Menu shortcut resolved to the isolated `Tipoff.exe`. The user's installed/running copy was not replaced during this check.

## Windows game-card text contrast — October 23, 2026

- Darkened the shared game-card text accent from bright mint `#19B98A` to deep teal `#087F5B` for broadcaster names, preferred-team labels, and the Altitude Details control. Selected-control borders retain the brighter mint, preserving the established palette without using it for small text.
- Calculated contrast against the `#F3F6F5` card surface: **4.60:1**. Windows fixture runner: **29 tests executed, 29 passed**. `scripts/package-windows.ps1`: **passed**, including WPF compilation.

## Windows routine disclaimer removal — October 23, 2026

- Removed the persistent limited-coverage banner from NFL, WNBA, NHL, and ESPN-fallback views. The footer still names the active source, including explicit ESPN fallback labels, without spending the compact content area on static caveats.
- Preserved visible messages for actual refresh failures, saved-data fallback, and Altitude supplement failures or mismatches. The snapshot's `LimitedCoverage` field remains intact for cache compatibility and command-line diagnostics; only the repetitive flyout presentation changed.
- Updated `AGENTS.md` so future work preserves source/fallback labeling without reintroducing routine UI disclaimers. Windows fixture runner: **29 tests executed, 29 passed**. `scripts/package-windows.ps1`: **passed**, including WPF compilation.

## Windows compact game cards — October 23, 2026

- Reduced game-card vertical padding from 10 to 3 logical units per side and inter-card spacing from 8 to 3. Team-line margins were removed, the preferred-team label moved into the time column, and empty preferred labels and game notices now collapse instead of reserving blank lines.
- Preserved the existing three-column team / time / broadcaster structure, 360-unit flyout width, typography hierarchy, mint preferred-team treatment, source-provided broadcaster wrapping, notices, and expandable Altitude details. Long team or broadcaster text and real game notices can still increase a card's height rather than being clipped.
- Windows fixture runner: **29 tests executed, 29 passed**. `scripts/package-windows.ps1`: **passed**, including WPF XAML compilation. The rebuilt packaged app launched and remained responsive; final density and wrapping across unusual long listings remain hands-on checks.

## Windows transparent basketball icon — October 23, 2026

- Replaced the generated dark Material Icons basketball with a transparent-background teal-and-charcoal basketball derived from the original Tipoff artwork. The rounded-square tile is absent; the dark seams remain opaque. The original `img/Tipoff.png` and the separate macOS icon pipeline are unchanged.
- `scripts/generate-windows-icon.ps1` now crops the source artwork's presentation padding, applies a circular edge clip, retains a small optical margin for the notification area, and emits the same nine PNG-backed ICO sizes from 16 through 256 pixels. `scripts/package-windows.ps1` reproduces the icon from `img/Tipoff-transparent.png`.
- The obsolete Google Material Icons attribution and packaged Apache icon license were removed because the Windows icon no longer uses that geometry. The historical license file remains in the repository.
- Inspected the actual 16, 32, and 256-pixel ICO frames: the smallest frame retains a recognizable teal basketball and dark seams; larger frames preserve the clean circular edge and transparent surround. Final notification-area appearance on the user's display remains a hands-on check.
- Windows fixture runner: **29 tests executed, 29 passed**. `scripts/package-windows.ps1`: **passed** and produced the framework-dependent x64 package with the regenerated icon and without the obsolete packaged icon license. The final packaged app remained responsive in hidden startup mode with its existing Run registration.
- The expanded flyout header now loads a dedicated 256×256 PNG instead of asking WPF to choose a frame from the ICO. High-quality downscaling renders it at the existing 30×30 layout size; the tray continues using the multi-frame ICO. The generator reproduces both assets from the same transparent source.

## Windows NBA ordering and launch at sign-in — October 23, 2026

- Ported the macOS national-broadcast-first NBA display ordering to Windows for both NBA.com and ESPN fallback identities. Source-listed National / Streaming video games lead; recognized national brands in ESPN's generic TV / streaming category also qualify. League Pass, NBA TV, radio, regional-only, and missing listings remain in the later group. Nuggets lead within each group, TBD games remain last within their group, and saved snapshots receive the display preference without changing serialized content, source, coverage, or freshness.
- Added current-user launch at sign-in. First launch writes a quoted packaged-executable command with `--startup` to `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`; startup launches remain hidden in the notification area. The checked `Start Tipoff with Windows` tray action supports an explicit opt-out and refreshes the executable path when enabled. Registration failures surface through a notification rather than preventing the schedule UI from opening.
- Windows fixture runner: **29 tests executed, 29 passed**. New coverage includes national classification, League Pass / NBA TV / radio / regional exclusions, primary and ESPN identities, Nuggets in national and non-national groups, time and TBD ordering, saved-snapshot serialization preservation, and WNBA isolation.
- `scripts/package-windows.ps1`: **passed** and produced the framework-dependent x64 app at `dist/windows/Tipoff.exe`. Starting that executable with `--startup` left the tray process running and created the expected quoted current-user Run entry. A real sign-out/sign-in cycle remains a hands-on check.
- Live Windows `Tipoff.Check nba 2026-10-23`: **NBA.com, 12 games**. Knicks at Celtics and Rockets at Spurs, both source-listed Prime Video games, appeared first at 5:00 PM and 7:30 PM Mountain; the ten League Pass games followed starting with Bulls at Bucks at 2:00 PM. Primary decoding succeeded. The initial sandboxed request could not resolve ESPN; the required unrestricted retry succeeded.
- At that validation step, the app icon was intentionally left unchanged for separate follow-up work; the completed icon update is recorded above.

## PC ordering handoff note — October 23, 2026

- Historical handoff record: documented the then-pending Windows port of macOS commit `ea9b6ce`, including implementation locations, ordering rules, saved-data requirements, and Windows validation commands. The completed port and current evidence are recorded above.
- Documentation-only change: **0 app tests executed**; reviewed content, relative file links, and diff whitespace. No rebuild required.

## macOS NBA national broadcast ordering — October 23, 2026

- NBA listings now put source-listed national TV/streaming games before League Pass, NBA TV, regional-only, and missing listings. Nuggets lead within each group; remaining games retain chronological order. ESPN fallback entries without a national category recognize ABC, ESPN variants, NBC, Peacock, and Prime variants. Radio does not affect priority. This does not determine actual League Pass eligibility or change source/coverage warnings.
- Display-only ordering applies to saved snapshots, including older NBA snapshots without an explicit guide, without changing game arrays, broadcasters, source, coverage flags, or freshness. At that validation step, other sports and the Windows app retained their existing ordering; Windows parity is recorded above.
- `scripts/test.sh`: **57 tests passed**, including four parameterized guide-switch cases (**60 individual test/case executions**). Added two regression tests covering national/streaming brands and categories, NBA TV/League Pass/radio/regional exclusions, primary and ESPN fallback identities, mixed national/League Pass listings, Nuggets priority within groups, chronological/TBD ordering, saved snapshot equality, and WNBA isolation. Updated the previous Nuggets-first test to exercise national Nuggets priority within the national group.
- `scripts/package-app.sh`: **passed**, including release build and strict code-signature verification. Output: ignored `dist/Tipoff.app`.
- Live `swift run TipoffCheck 2026-10-23`: **NBA.com, 12 games**, no limited-coverage flag. Knicks at Celtics (5:00 PM Mountain) and Rockets at Spurs (7:30 PM Mountain), both source-listed Prime Video games, appeared first; the ten League Pass listings followed, starting with Bulls at Bucks (2:00 PM). Fetching, decoding, and cache schema remain unchanged.
- README, plan, data notes, and settings wording updated; diff whitespace checked. No new release published or Windows parity claimed.

## Windows system-tray app

- Built a native C# / WPF companion under `Windows/`, targeting .NET 9 on Windows x64. The packaged flyout is 360 logical units wide, uses the Tipoff icon and mint/rounded-card treatment, opens on first launch, toggles from the tray icon, and exposes Open / Refresh / Quit tray actions. The macOS source and packaging remain separate.
- Simplified the shared header to the `Tipoff` name without a sport-specific viewing-guide subtitle, removed the `No scores. Just where to watch.` settings/tray slogan, and replaced the padded mint icon with a transparent full-bleed dark basketball. The first custom seam drawing was rejected during review and replaced with the recognizable eight-panel `sports_basketball` geometry from Google Material Icons. The Windows ICO contains nine PNG-backed sizes from 16 through 256 pixels and is regenerated by `scripts/package-windows.ps1`; the macOS generator uses the native basketball symbol in the same dark treatment. Attribution and the Apache 2.0 license are included in the repository and Windows package.
- Ported strict schedule-only models and decoders for NBA.com, ESPN NBA fallback, ESPN NFL/WNBA, NHL.com and MLB.com with ESPN fallback. Caches are isolated by sport, calendar day, and Windows time-zone ID under `%LOCALAPPDATA%\Tipoff\Schedules\Windows\`; failed refreshes preserve saved data and original freshness. The Windows app now also decodes Altitude’s Nuggets table, requires date/opponent/home-away/tipoff agreement, preserves regional footnotes and show times in expandable Details, and keeps its saved supplement and original timestamp separately at `%LOCALAPPDATA%\Tipoff\Altitude.Windows.json`.
- Windows fixture runner: **28 tests executed, 28 passed**. Coverage includes NBA page parsing and rejection cases, ESPN parsing, source broadcaster preservation, no-score serialization, local/Eastern source dates, Nuggets/Broncos/Avalanche/Rockies identity and priority, NHL country filtering, MLB TV/streaming brands and radio exclusion, cache isolation, the 85-row Altitude fixture, Mountain DST, network variants, regional notes, strict matching, duplicate suppression, malformed pages, score-free supplement serialization, and failed refreshes with and without saved supplement data.
- Live Windows `Tipoff.Check` results: focused Altitude page — **85 listings**; NBA `2026-10-24` — **NBA.com + Altitude, 8 games**, with Pelicans at Nuggets first and Altitude / Altitude+ / KTVD-20* / League Pass; NFL `2026-10-25` — **ESPN, 12 games**; WNBA `2026-06-21` — **ESPN, 3 games**; NHL `2026-10-22` — **NHL.com, 12 games**; MLB `2026-07-01` — **MLB.com, 14 games**. Source-provided broadcasters were printed; NBA/NHL/MLB primary sources decoded successfully and ESPN-only guides retained their coverage warning. The live check also exposed gzip transport handling required by Altitude’s current page response; automatic decompression is now enabled.
- `scripts/package-windows.ps1`: **passed** after the Altitude and branding changes and produced the ignored framework-dependent x64 output at `dist/windows/Tipoff.exe`, including the MIT license, notice, and Apache 2.0 icon license. The package requires the .NET 9 Desktop Runtime; no installer, signature, or public Windows release is claimed.
- Hands-on Windows inspection exercised initial NBA rendering, sport selection, loading state, NFL coverage warning, Sunday shortcut, scrolling, Denver-first ordering, source/freshness footer, and Quit. It exposed and led to fixes for NFL display re-sorting, Quit being intercepted by the hide-on-close guard, and loaded content expanding below the taskbar. The final packaged check showed Broncos first, kept the full footer on-screen after async loading, and exited cleanly.
- Fresh automated hands-on inspection of the Altitude Details expansion and simplified branding was attempted, but the configured Windows computer-control service was unavailable. The packaged XAML compiled cleanly and the icon artwork was inspected at 16, 64, and 256 pixels; checking the final live 360-unit layout and exercising Quit remain hands-on checks.
- The existing macOS `scripts/test.sh` and `scripts/package-app.sh` require macOS/SwiftUI tooling and were not executable on this Windows host. No Swift networking/source code changed; the latest recorded macOS validation below remains applicable.

## Windows documentation refresh

- Updated the README, product plan, data notes, and current Windows validation summary to describe the system-tray app, simplified branding, Altitude supplement, source-build limitations, icon generation, and Apache 2.0 attribution consistently.
- Preserved the original 2048×2048 app icon at `img/Tipoff.png`; the then-current dark, full-bleed Windows tray icon remained a separate generated platform asset. Its later replacement is recorded above. The older macOS screenshot is retained as a feature reference but removed from the README hero because it predates the simplified header.
- Markdown links, targeted wording, original PNG dimensions/transparency, and diff whitespace checked. **0 app tests executed** for this documentation-only change; no source, model, networking, cache, or packaging behavior changed.

## GitHub screenshot and documentation refresh

- Copied the user-provided October 22 screenshot unchanged to `docs/current-preview.png` (PNG, 968×1044); it was originally displayed in the README at 484 pixels wide with a dated caption and descriptive alternative text. It shows all five sport tabs, Nuggets emphasis, and the open broadcast details popover. Older previews remain available.
- Reviewed README scope, source/coverage limitations, build instructions, version 0.4.1 packaging metadata, and GitHub release state. The latest published download remains NBA-only v0.2.0; current five-sport code is available from source. No new binary release is claimed. Corrected the obsolete two-guide statement in `docs/DATA.md` and clarified the menu bar icon instruction.
- Updated the GitHub repository description to name NBA, NFL, WNBA, NHL, and MLB.
- Image copy hash, PNG dimensions, local documentation/image links, and diff whitespace checked. **0 app tests executed** for this screenshot/documentation-only change; no app rebuild or live source check required. The prior implementation validation below remains the latest app test evidence.

## Rockies and Avalanche preference — version 0.4.1

- Rockies games appear first within MLB and Avalanche games first within NHL, with mint outline and uppercase team label matching Nuggets/Broncos. Other games stay chronological; multiple preferred games retain their own time order. The display preference also applies to older saved snapshots without changing stored game arrays, broadcasters, source/coverage fields, or original freshness.
- `scripts/test.sh`: **55 tests passed**, including four parameterized guide-switch cases (**58 individual test/case executions**). Two new regression tests cover both venues, NHL/MLB primary and ESPN fallback identities, cross-sport isolation, saved snapshot round-trips, preserved data/freshness, multiple preferred games, and empty lists. Existing Nuggets/Broncos tests still pass.
- Live `TipoffCheck 2026-07-01 --mlb`: **MLB.com, 14 games**, Miami at Colorado displayed first at 6:40 PM local time with source-listed Rockies.TV; remaining games chronological. Live `TipoffCheck 2026-10-23 --nhl`: **NHL.com, 2 games**, Tampa Bay at Colorado displayed first at 7:00 PM, with source-listed The Spot / ALT. The check tool now prints the same display order as the UI.
- Inspected native dark/light renders of both preferred rows at the existing 360-point width. Team labels, mint outlines, source-provided long network names, coverage warning, and freshness footer fit without clipping. Updated `docs/mlb-preview.png` and `docs/nhl-preview.png`.
- `scripts/package-app.sh`: **passed**, release build and strict code-signature verification, **0.4.1 (8)**; packaged Info.plist lint passed. Relaunched the local packaged app for user testing. Source fetching/decoding and cache schema are unchanged; no viewing availability is inferred and no Avalanche/Altitude supplement is added.
- README, plan, data notes, and repository instructions updated. Local documentation links and diff whitespace checked before commit. App remains a personal tool shared as-is; no release publication is claimed.

## WNBA, NHL, MLB — version 0.4.0

- Added sports in the requested order: WNBA, NHL, MLB. The 360-point selector is now NBA / NFL / WNBA / NHL / MLB. WNBA uses ESPN; NHL and MLB use league feeds with labeled ESPN fallback. NBA/NFL caches and Nuggets/Broncos emphasis remain compatible; new guides have isolated cache prefixes and no team/sport identity collisions. Today applies to WNBA/NHL/MLB; Sunday remains NFL-only.
- `scripts/test.sh`: **53 tests passed** (Swift Testing summary), including **four executed cases** for the parameterized guide-switch/stale-response test. There are 52 ordinary tests plus four parameterized cases, or **56 individual executions**. Added 13 test functions beyond the 40-test baseline: WNBA fixtures, strict league/schema validation, empty/TBD/postponed days, local-midnight/duplicate handling, NHL source-day/count/country filtering and missing listings, MLB regional streaming names/radio exclusion, doubleheader identity, malformed/partial feeds, primary/fallback attribution, score-free caches, and saved freshness on total source failure. A malformed NHL schedule-state case initially revealed that an unknown state was accepted; the decoder now rejects unknown states and the final suite passed.
- Live WNBA `TipoffCheck 2026-06-21 --wnba`: **ESPN, 3 games**, with source-listed CBS/Paramount+, NBA TV/local networks, and ESPN/Disney+. Current-day `2026-10-22 --wnba`: **ESPN, 0 games**. Empty-day UI makes no season-ended or eligibility claim.
- Live NHL `TipoffCheck 2026-10-22 --nhl`: **NHL.com, 12 games**. US-tagged TV/streaming names retained, Canadian entries excluded, coverage warning visible. `2026-07-01 --nhl`: **NHL.com, 0 games**, accepted as a valid empty schedule.
- Live MLB `TipoffCheck 2026-07-01 --mlb`: **MLB.com, 14 games**, including source-provided Rockies.TV and regional networks. `2026-10-23 --mlb`: **MLB.com, 1 game**, with FOX / FOX ONE and Fox Deportes / FOX ONE. `2026-10-22 --mlb`: **MLB.com, 0 games**. Duplicate home/away entries for the same national network collapsed within their category. Unusual suspension/resumption cases still warrant publisher checks; no comprehensive resumption guarantee is made.
- Live regression NBA `2026-10-24`: **NBA.com + Altitude, 8 games**, matching Nuggets channels and time retained. NFL `2026-10-25 --nfl`: **ESPN, 12 games**, Broncos first. Source/network failure paths were exercised through URLProtocol, including malformed first-party responses falling back to ESPN and total failures preserving saved snapshots.
- Inspected native dark and light renders for populated WNBA, NHL and MLB views, plus the empty WNBA view. Five sport tabs, long teams/networks, scrolling, sport icons, coverage notice and freshness footer fit the existing layout. Dark artifacts: `docs/wnba-preview.png`, `docs/nhl-preview.png`, `docs/mlb-preview.png`. Also inspected a long regular-season MLB render with sponsor-bearing publisher names wrapping in the broadcaster column.
- `scripts/package-app.sh`: **passed**, release build and strict code-signature verification, **0.4.0 (7)**. `plutil -lint` passed; Mach-O executable confirmed **arm64**. Packaged NOTICE matches the updated source notice. App remains ad-hoc signed and not notarized. Local packaged app relaunched for user testing; no GitHub release publication is claimed.
- README, plan, source details, historical research status, repository instructions, and NOTICE updated. Checked local Markdown links, diff whitespace, and new fixture fields for absence of score/clock/standings/record/odds data. Only the minimal schedule/broadcast fields are retained in new fixtures.
- Remaining hands-on checks: interactive sport switching, scrolling, login/wake behavior, and local reception/subscription availability. No independent WNBA fallback or Avalanche/Altitude supplement is implemented. These are undocumented website dependencies with incomplete listing/rights coverage.

## Nuggets first with Broncos-style emphasis

- Nuggets games appear first in NBA with a mint outline and NUGGETS label matching the Broncos treatment. Other NBA games remain chronological. Display ordering also applies to existing saved snapshots without changing stored listings or freshness. NFL ordering remains unchanged.
- `scripts/test.sh`: **40 executed, 40 passed**. One new regression covers home/away Nuggets games from both NBA.com and ESPN, saved snapshot round-trips, preserved freshness/data, chronological remaining games, NFL identity/order, and empty schedules.
- `scripts/package-app.sh`: **passed**, including release build and strict signature verification.
- Live `.build/debug/TipoffCheck 2026-10-24`: **NBA.com + Altitude, 8 games**. Production-view dark/light renders show Pelicans at Nuggets first, with supplied Altitude channels, Details, and freshness information intact at the existing 360-point width. Dark preview: `docs/nuggets-first-preview.png`. Interactive menu bar behavior remains a hands-on check.
- README, plan, and settings text updated; diff whitespace checked before commit.

## PNG icon export

- Copied the highest-resolution existing icon asset to `img/Tipoff.png`; verified it matches the source byte-for-byte.
- `sips` confirmed PNG format, 2048×2048 pixels, and an alpha channel; visually inspected the exported icon.
- Diff/content checks passed. **0 tests executed** for this asset/documentation-only change; no app rebuild or live source check needed.

## Day navigation click targets

- Previous/next day buttons now use 28×28-point label frames with rectangular content shapes, so the empty area around each chevron accepts clicks. Chevron styling and the 360-point popover width remain intact.
- `scripts/test.sh`: **39 executed, 39 passed**. No new tests added for this small view-only change.
- `scripts/package-app.sh`: **passed**, including release build and strict signature verification.
- Live `TipoffCheck 2026-10-21`: **NBA.com, 11 games**. Inspected a native dark render of the updated view; date navigation and game layout fit without clipping. Interactive edge clicks remain a hands-on check.
- README and plan updated; diff whitespace checked before commit.

## WNBA / MLB / NHL source research

- Documentation-only investigation; runtime and packaged version remain 0.3.2. No app tests, package build, or `TipoffCheck` run was introduced for this research. The last executed implementation baseline remains **39 tests passed**.
- Direct HTTP/JSON probes verified ESPN feeds for all three sports, MLB's schedule/broadcast feed, NHL's week and Avalanche season feeds, and Altitude's `/avs-broadcasts` table. Several WNBA dates were checked so a single empty day was not mistaken for source failure. Tested candidate WNBA CDN URLs did not return usable JSON; no first-party WNBA JSON feed is claimed verified.
- Recorded exact sample dates, counts, endpoints, broadcaster differences, and implementation gaps in `docs/SOURCE-RESEARCH.md`. Raw responses stayed outside Git; only schedule-related observations are recorded. No new sport support, decoder test coverage, or availability guarantee is claimed.
- README and plan link the findings. Checked local documentation links and diff whitespace before commit.

## NFL Sunday shortcut — version 0.3.2

- NFL replaces the date navigation's Today action with Sunday, visible on non-Sunday dates including today. It jumps to the upcoming local Sunday relative to the current date (today if already Sunday), rather than a Sunday relative to a browsed historical/future date. Sunday views hide the shortcut. NBA retains Today.
- Date calculation uses calendar-day addition in the Mac's time zone. The selected Sunday remains selected when reopening/refreshing; normal today-following behavior still applies when the target is today.
- `scripts/test.sh`: **39 executed, 39 passed**. Two new tests cover weekday/Sunday behavior, local Saturday versus UTC Sunday, DST dates, New Year, and jumping from a distant browsed date.
- Live `TipoffCheck 2026-10-20 --nfl`: **0 games**. Live `TipoffCheck 2026-10-25 --nfl`: **12 games**, Denver first. Native renders inspected: Sunday action visible on October 20 and absent on October 25, with compact layout intact.
- `scripts/package-app.sh`: **passed**, release build and strict signature verification, version **0.3.2 (6)**. Relaunched the packaged local app for user testing. README and plan updated; local Markdown links and diff whitespace checked before commit.

## Broncos within NFL — version 0.3.1

- Only NBA and NFL remain in the top-level selector. Broncos matchups appear within NFL's selected-day schedule, with Denver first and a mint outline. Removed the separate Broncos window, team-schedule requests, decoder, and associated fixtures. Old window caches are ignored; existing NBA/NFL daily caches keep their keys.
- `scripts/test.sh`: **37 executed, 37 passed**. Removed four tests for the deleted team-schedule feature and added an explicit NBA/NFL-only guide test. Existing daily NFL decoder, malformed/schema-change, cache isolation, source-date/DST, score exclusion, failure, and stale-response tests still pass.
- Live `TipoffCheck 2026-10-25 --nfl`: **12 games**, Denver at Arizona first with ESPN-listed CBS and 2:05 PM local kickoff. Live `TipoffCheck 2026-10-24`: **NBA.com + Altitude, 8 games**, matching Nuggets supplement retained.
- Inspected dark and light native renders: only NBA/NFL tabs, Denver highlighted inside the NFL list, 360-point width, source/coverage/freshness information intact. Updated `docs/nfl-preview.png`. The older Broncos screenshot below documents the superseded 0.3.0 design.
- `scripts/package-app.sh`: **passed**, release build and strict signature verification; `plutil -lint` passed. Packaged **0.3.1 (5)** and relaunched the local `dist/Tipoff.app` for user testing. Interactive switching remains a user check.
- Updated README, plan, source documentation, and repository instructions. Local Markdown links and diff whitespace checked before commit.

## NFL / Broncos — version 0.3.0

- `scripts/test.sh`: **40 executed, 40 passed** after the final source, test, and fixture changes (28 existing and 12 NFL/Broncos tests). New coverage includes real sanitized daily/team/preseason fixtures, source-listed broadcasters, wrong league/season/type, malformed entries and schema changes, valid empty schedules, TBD kickoffs, local-day filtering, Denver priority, 35-calendar-day windows across DST/New Year, guide cache isolation and legacy NBA snapshots, excluded score/clock/record fields, regional/radio handling, and stale response rejection with saved-cache preservation on failure.
- Live `TipoffCheck 2026-10-20 --broncos`: ESPN Broncos schedule, **4 games** in October 20–November 23. Dates: October 25, November 1, November 8, November 22. CBS listed directly by ESPN; no streaming or local affiliate added. Preseason, regular-season, and postseason requests completed. ESPN's root current-season phase differs from requested preseason metadata; validation uses the requested/event phase rather than assuming they match.
- Live `TipoffCheck 2026-10-25 --nfl`: ESPN NFL, **12 games**, Broncos at Cardinals first, 2:05 PM local time. Other games remain visible in time order after Denver. Coverage warning shown.
- Live regression `TipoffCheck 2026-10-24`: **NBA.com + Altitude, 8 games**. Pelicans at Nuggets at 7:00 PM local time still matches Altitude / Altitude+ / KTVD-20*.
- Inspected native SwiftUI dark and light renders for Broncos and NFL. Selector, dated Broncos rows, mint emphasis, coverage warning, source/freshness footer, and scrolling NFL list fit the 360-point layout. Dark artifacts: `docs/broncos-preview.png`, `docs/nfl-preview.png`. The check renderer now takes its selected date from the snapshot day so multi-day previews retain the correct window origin.
- `scripts/package-app.sh`: **passed**, release build and strict code-signature verification. Bundle metadata: **0.3.0 (4)**. `plutil -lint` passed; packaged executable confirmed **arm64**. Build is ad-hoc signed, not notarized. App output is in ignored `dist/Tipoff.app`; no installation or GitHub release publication is claimed.
- Documentation/diff/link checks passed. Fixtures retain public schedule fields only; no raw website response or telemetry is persisted by the app. Existing NBA caches keep their filenames; NFL and Broncos use separate prefixes under the shared 45-snapshot cap.
- Remaining manual checks: interactive menu bar switching/scrolling, launch-at-login approval and OS wake behavior. Rendering exercises the production views; URLProtocol and controlled-provider tests exercise failure/cancellation behavior. NFL currently has ESPN as its only source, and future unassigned matchups may be absent.

## Public-sharing review using Agentic Toolkit v0.2

- Applied the toolkit's `core/GITHUB-PROJECT-PAGES.md` version 0.2, from toolkit commit `8b30f57e79a7bb2d298f027c2db841dd1ba1463f`.
- Confirmed that the repository is already public and v0.2.0 is published with an Apple Silicon archive and checksums. Anonymous repository and release-download access returned HTTP 200.
- Reviewed the existing README, AGENTS.md, license/notice, source entry point, package/build metadata, validation notes, and existing open issues. No open GitHub issues were listed at this review; this is not a claim that the app is bug-free.
- Added the already-known upstream broadcast-coverage gaps to README's Known issues section, with a suggestion to check the broadcaster's own schedule for missing options.
- Changes are documentation-only. Runtime source, packaging, and resources match the v0.2.0 tag, so the existing release remains applicable. No new bug sweep, repair backlog, rebuild, or test run was introduced. The 28-test result below is the prior executed baseline.
- Checked documentation links, image references, and diff whitespace for the updated files. Review of the changed public text found no added personal data or credentials; the original publication's history review remains recorded below.

## Public sharing preparation — v0.2.0

- README rewritten for a personal tool shared as-is, with screenshots, source/build/install instructions, current scope, and clear Apple Silicon / ad-hoc signing / no-notarization limits. Detailed source documentation lives in `docs/DATA.md`.
- MIT license and third-party notice added; both are included in the packaged application.
- Scanned all 45 pre-publication historical file blobs for common credential formats and raw visitor metadata assignments; no matches. Reviewed tracked paths: no build outputs, schedule caches, signing material, or credentials are tracked. Original commit author names/emails remain in history.
- `scripts/test.sh`: **28 executed, 28 passed**. `scripts/package-app.sh`: passed; no runtime behavior changes in this preparation.
- Packaged `Tipoff-0.2.0-macos-arm64.zip` and `SHA256SUMS` for a basic GitHub release. Verified archive members, license/notice inclusion, extracted app code signature, and Mach-O arm64 architecture. No Intel or notarization claim is made.
- Local Markdown/image links and diff whitespace checks passed.

## Altitude Nuggets supplement — version 0.2.0

- `scripts/test.sh`: **28 executed, 28 passed** after the final changes. Includes 13 new Altitude cases: actual schedule fixture (85 dated games; unassigned Cup placeholders ignored), channel variants, neutral sites, national-only games, market notes, duplicate broadcasters, strict matchup/tipoff agreement, changed game suppression, Mountain DST, malformed pages/headers/missing footnotes, score-free cache round-trip, and failed-refresh handling with and without saved data.
- Live `TipoffCheck 2026-10-24`: NBA.com + Altitude, 8 games. Pelicans at Nuggets at 7:00 PM MDT matched; Altitude, Altitude+, KTVD-20*, regional note, pregame/postgame data loaded.
- Live `TipoffCheck 2026-10-28`: NBA.com + Altitude, 12 games. Nuggets at Pelicans at 6:00 PM MDT matched; Altitude 2, Altitude+, KTVD-20* loaded. Pregame 5:30 PM and postgame 8:30 PM MDT came directly from Altitude.
- Inspected native dark renders of the Nuggets row and its actual Details view: channels, regional footnote, times, and original Altitude check timestamp visible without clipping. Preview snapshot was filtered to the Nuggets game for visual review; the app still shows all games. Artifacts: `docs/altitude-preview.png`, `docs/altitude-details.png`.
- Fixture retains only the public raw schedule table inside a minimal page wrapper. No page visitor metadata, IP, or embedded service configuration is included.
- `scripts/package-app.sh`: release build and signature verification passed for 0.2.0; installed at `~/Applications/Tipoff.app` and relaunched.
- Actual popover interaction remains a hands-on check; renders use the same SwiftUI views. Source failures and saved-data behavior were exercised with URLProtocol responses, not by interrupting the user's connection.

## Layout update — version 0.1.1

- Radio hidden from the popover; retained only in the underlying source model.
- Each game is one row with three columns: stacked away/home teams, local start time, and TV/streaming listings. Team names replace redundant tricode labels in the compact layout.
- List height follows measured content, capped at 450 points before scrolling. Long team and broadcaster names wrap without truncation.
- `scripts/package-app.sh`: release build and signature verification passed; installed and relaunched `~/Applications/Tipoff.app` version 0.1.1.
- `scripts/test.sh`: **15 executed, 15 passed** after the final layout change. No new tests added for this visual change.
- Dark render inspected with the three opening-day games; light render inspected with synthetic long team/network names and multiple broadcast groups. No radio controls or clipped row content. Updated `docs/preview.png`.

## Initial build checks

- `swift build`: passed.
- `scripts/test.sh`: **15 tests executed, 15 passed**. Covers live-source fixtures, streaming/radio decoding, rejection of challenge/wrong-date/paginated data, legitimate empty days, ESPN minute-precision timestamps, timezone/DST boundaries, cache isolation/corruption, preservation of offline data, stale async response rejection, postponements, and exclusion of scores from persisted models.
- `scripts/package-app.sh`: release app built and code signature verified. Packaged bundle approximately 1.1 MB. Info.plist validation passed.
- Live `TipoffCheck 2026-10-20`: NBA.com primary succeeded, 3 games; Peacock and NBC for each. Mountain start times: 1:00 PM, 5:00 PM, 7:30 PM. No fallback was needed.
- Live `TipoffCheck 2026-10-21`: NBA.com primary succeeded, 11 games. Source-provided national, subscription, and radio listings parsed.
- Direct Swift URLSession request to NBA CDN schedule endpoint returned HTTP 403. The accessible NBA Games page is used instead.
- Offscreen AppKit/SwiftUI renders inspected in dark and light appearances: all three opening-day games visible, source/time freshness footer visible, no clipping. Final dark preview: `docs/preview.png`.
- Installed `~/Applications/Tipoff.app`, verified its signature, launched it, and confirmed its executable remained running.

## Remaining hands-on checks

- Click the actual menu bar icon and exercise previous/next day, refresh, and Settings. Native UI automation timed out on the windowless menu bar app, so this was not verified through automated clicks.
- Enable launch at login and verify after a real login; left off during development.
- Exercise real sleep/wake, a real system timezone change, and network loss/recovery with the installed app. Offline preservation and request races passed automated tests.
- ESPN fallback decoder passed recorded live-fixture tests; a forced NBA outage with the installed app was not performed.

## Known limits

Website endpoints are undocumented and can change. NBA.com itself omitted local TV listings for several upcoming games in the samples; ESPN also omitted some local/streaming options. No source can presently be claimed complete or covered by an availability SLA. Tipoff only shows supplied listings and does not infer subscription or blackout eligibility. Deferred: broadcaster watch links, global regions, and additional sports.

Live verification repeated both November 7 (national headline hidden, revised empty message) and November 8 (national headline restored with games). Screenshot: `/tmp/tipoff-empty-national-live.jpg`.
