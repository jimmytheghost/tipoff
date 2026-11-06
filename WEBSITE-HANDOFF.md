# Tipoff website handoff

Updated November 5, 2026. Status: preparation. The browser guide is planned. The current [Tipoff source](https://github.com/jimmytheghost/tipoff) ships native macOS and Windows apps.

## Page and routes

- Build one public viewing guide at `https://www.jimmyweber.com/tip-off`. Redirect `/sports` to it and use the main URL in the page metadata. Verify slash variants and the final host with the site's routing.
- Keep the existing [Tipoff portfolio entry](https://www.jimmyweber.com/pages/projects/tipoff/) as the overview for the native apps.
- Open to **All** and show today’s schedule grouped by league. Keep an empty section visible for a league with a successfully fetched schedule and no games. Use **All**, **NBA**, **NFL**, **WNBA**, **NHL**, and **MLB** controls to narrow the view. Keep the date consistent when switching leagues.
- Use the visitor’s time zone for the calendar date and game times. Provide Today and previous/next day controls. Show teams, scheduled start times, and source-listed broadcasters. Use existing JimmyWeber.com type, navigation, spacing, and controls, with readable stacked game details on phones. Use text labels for the controls and expose the selected state to assistive technology.

## Schedule integration

The current site workspace documents Apache and PHP 8.1 in its deployment guide. Confirm the production runtime, outbound requests, and writable cache location before settling on the data path. Use shared site includes and styles for the page and keep the schedule endpoint and cache separate from the site's templates and deployment payload. The source contracts and fixtures in this repository are the reference for any web adapter. Reusing a schedule producer is preferable if it can run in the target environment. No web runtime or refresh service has been selected.

- NBA.com with ESPN fallback for NBA, ESPN for NFL and WNBA, and the respective league feed with ESPN fallback for NHL and MLB. Carry the Nuggets Altitude supplement only with agreement on date, opponent, home/away, and tipoff. Keep regional footnotes and original freshness on saved results.
- Keep saved schedules separate by sport, local date, and time zone. Preserve each sport’s working snapshot through upstream errors or malformed data. Show per-sport source, timestamp, fallback or saved state, and unavailable state as applicable. Only display “No games scheduled” after a valid empty result for the selected day. One league failure should leave other leagues usable.
- Preserve native display ordering, including national NBA listings first and Nuggets priority within each group, plus Broncos, Avalanche, and Rockies priority in their respective sports. Use calendar days across time-zone boundaries and daylight saving transitions. Persist only schedule and broadcaster fields. Exclude scores, standings, and live telemetry, and avoid inferring streaming eligibility or local rights.

## Link preview and integration checks

Use **Tipoff** as the preview title and “Game times and broadcast listings for the NBA, NFL, WNBA, NHL, and MLB” as the proposed description. The existing portfolio preview is a 1920 × 1080 Tipoff banner. Inspect its crop at phone-card size before reusing it. Include the canonical URL and an absolute image URL in the initial HTML’s Open Graph and Twitter metadata. See [link preview requirements](core/LINK-PREVIEWS.md).

Before release, verify both shortcuts, direct visits and reloads, phone and desktop layouts, keyboard use, date navigation around midnight and daylight saving changes, and schedule behavior with fresh, empty, failed, and saved feeds. Check the actual preview image and crawler metadata on both URLs. Record the deployment file list, verification results, and rollback in the website workspace.

The public homepage and Tipoff portfolio page returned HTTP 200 on November 5, 2026. Both proposed short URLs returned HTTP 404. The web guide, mobile layout, feed integration, and message preview are still pending.
