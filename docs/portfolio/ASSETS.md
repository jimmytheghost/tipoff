# Tipoff portfolio assets

Prepared November 7, 2026. Captions and alt text below are ready to use. Keep originals available for enlargement. Screenshots show historical schedules, not currently verified viewing access. Team/network artwork belongs to its respective owners; capture provenance does not grant independent rights to those logos. No scores or live telemetry were added.

## Page-ready files

### tipoff-overview.png

- File: [assets/tipoff-overview.png](assets/tipoff-overview.png) — 1800 × 1120, editorial composition.
- Caption: Tipoff on macOS and in the browser. Composite of native view and live website captures.
- Alt: Tipoff icon above a macOS schedule view and the desktop browser guide.

### macos-nba-dark.png

- File: [assets/macos-nba-dark.png](assets/macos-nba-dark.png) — 720 × 1330, native view render.
- Caption: The macOS guide in Dark appearance, with Nuggets listings first. Production-view render using November 7, 2026 listings.
- Alt: Dark macOS Tipoff guide showing five sport tabs and Nuggets at Pacers with Altitude 2, Altitude+, and NBA TV listings.

### macos-nba-light.png

- File: [assets/macos-nba-light.png](assets/macos-nba-light.png) — 720 × 1330, native view render.
- Caption: The same macOS guide in Light appearance. Production-view render.
- Alt: Light macOS Tipoff guide with five sport tabs, teams, local game times, and supplied broadcasters.

### macos-altitude-details.png

- File: [assets/macos-altitude-details.png](assets/macos-altitude-details.png) — 616 × 480, native view render.
- Caption: Matching Altitude listings include show times, regional notes when supplied, and their original check time. Production-view render.
- Alt: Nuggets broadcast details from Altitude with game, pregame, postgame, and source freshness information.

### windows-feature-diagram.png

- File: [assets/windows-feature-diagram.png](assets/windows-feature-diagram.png) — 1600 × 900, feature diagram.
- Caption: The Windows app’s tray, guide, and settings flow. Explanatory feature diagram, not a Windows screenshot.
- Alt: Diagram describing the Windows tray icon, five-sport flyout, and Light, Dark, and startup settings; not a screenshot.

### web-following-desktop.jpg

- File: [assets/web-following-desktop.jpg](assets/web-following-desktop.jpg) — 1440 × 1000, live browser capture.
- Caption: Following highlights the Nuggets and Avalanche on November 7, 2026. No national broadcasts are listed for this selection.
- Alt: Desktop browser guide with Nuggets and Avalanche highlights and All Games collapsed.

### web-national-desktop.jpg

- File: [assets/web-national-desktop.jpg](assets/web-national-desktop.jpg) — 1440 × 1037, live browser capture.
- Caption: The browser guide on November 8, 2026, with Broncos coverage in Following and the remaining national listings below.
- Alt: Desktop Tipoff browser guide showing Broncos at Panthers and national NFL broadcasts with local start times.

### web-all-games-desktop.jpg

- File: [assets/web-all-games-desktop.jpg](assets/web-all-games-desktop.jpg) — 1440 × 2679, live browser capture.
- Caption: All Games expands the full schedule and five league filters below the highlights.
- Alt: Expanded desktop All Games section with All, NBA, NFL, WNBA, NHL, and MLB filters and daily schedules.

### web-national-mobile.jpg

- File: [assets/web-national-mobile.jpg](assets/web-national-mobile.jpg) — 390 × 1097, live browser capture.
- Caption: The November 8 browser guide at a 390-pixel phone viewport.
- Alt: Phone layout of Following and national NFL broadcasts with logos, matchups, and scheduled start times.

### web-calendar-mobile.jpg

- File: [assets/web-calendar-mobile.jpg](assets/web-calendar-mobile.jpg) — 390 × 844, live browser capture.
- Caption: The browser calendar at a 390-pixel phone viewport, with November 8 selected.
- Alt: Dark calendar popover over the phone schedule, showing November 2026 and the Today control.

### web-details-status-desktop.jpg

- File: [assets/web-details-status-desktop.jpg](assets/web-details-status-desktop.jpg) — 1280 × 720, live browser capture.
- Caption: Expanded Nuggets broadcast details and the source/freshness disclosure. The live NBA and MLB responses used ESPN fallback in this capture.
- Alt: Nuggets broadcaster details with pregame and postgame times, alongside the footer panel naming each sport’s source and update time.

### tipoff-social-v1.png

- File: [assets/tipoff-social-v1.png](assets/tipoff-social-v1.png) — 1200 × 630, link preview composition.
- Caption: Proposed portfolio link-preview artwork. Not deployed.
- Alt: Tipoff app icon with macOS and browser viewing-guide images.

## Provenance and reproduction

- macOS: `.build/debug/TipoffCheck 2026-11-07` fetched NBA.com + Altitude, seven games, during this task. `source/nba-2026-11-07.json` is the unmodified score-free schedule snapshot produced by that check. It includes public schedule/broadcaster fields and their original timestamps; no visitor data. Renders were made with the existing local TipoffCheck production-view renderer (binary built November 6). No source code was changed or recompiled. This is not an interactive menu-bar capture.
- To regenerate a native render, build TipoffCheck if necessary, copy the supplied snapshot to an ignored temporary path such as `.build/portfolio-render.png.json`, then run `.build/debug/TipoffCheck --render .build/portfolio-render.png`. Use `--light` or `--altitude-details` for the other variants. Copy only the PNG to its selected asset path. Regenerating on another day may change relative-date/freshness labels; do not edit the snapshot to make it appear newly fetched.
- Browser: captured from the live `/tipoff` route in the in-app browser, November 7, selecting November 7 or 8 through date controls. Desktop main captures used 1440-pixel width; expanded details/status used the 1280-pixel default viewport. Phone captures used a 390 × 844 viewport with no invented device frame. Team and broadcaster images loaded from the actual guide. The phone full-page image is 390 × 1097. Temporary viewport overrides were reset. Initial malformed phone-scale captures were replaced and visually checked.
- Reference-only full-page captures: the three URLs in HANDOFF.md, inspected the same day. They are for the next agent’s editorial comparison, not assets to publish within Tipoff.
- Overview/social: run `python3 docs/portfolio/source/create-artwork.py` from the repository. Pillow required; Arial/Arial Bold are loaded from macOS system fonts. Existing `img/Tipoff.png` plus unmodified macOS and browser captures are proportionally placed on a flat background. These are compositions, not an actual multi-platform desktop. The small text in social artwork is illustrative; project name and identifying artwork carry the preview.
- Windows: the same script draws an abstract feature-flow diagram based on `Windows/Tipoff.App/App.xaml.cs`, `MainWindow.xaml`, `MainViewModel.cs`, and `SettingsWindow.xaml`, plus README. It contains no simulated game listings, OS chrome, or claimed WPF render. Keep the prominent diagram label. No Windows desktop was accessible for this task.
- `python3 docs/portfolio/source/catalog-assets.py` rebuilds the manifest, this guide, and the contact sheet. Manifest hashes identify the exact delivered image bytes. The existing untracked `img/Tipoff-banner.png` was not used or changed.

## Optional Windows screenshot replacement brief

On a real Windows 10/11 x64 machine, follow README and `scripts/install-windows.ps1` to use the stable current-user installation. Capture: (1) Dark guide with the tray icon visible and a populated day, (2) the same guide in Light, (3) expanded Nuggets Altitude details if supplied for a matching day, and (4) Settings showing appearance and startup controls. Use the actual 360-unit flyout at a normal display scale; record display scaling, app revision, local date/time zone, selected schedule date, source, saved/fallback state, and whether startup was actually changed. Do not enable startup solely to stage a screenshot. Exclude unrelated tray icons, notifications, usernames, private paths, and other windows from the shared image. Preserve source/freshness labels and original timestamps. Save PNG captures with names `windows-guide-dark.png`, `windows-guide-light.png`, `windows-altitude-details.png`, and `windows-settings.png`. If a source fails, show the genuine saved/fallback state or choose another populated date; do not fabricate a healthy state. Add dimensions/provenance/captions to the manifest and replace the diagram only after inspecting the real captures.

## Reference-only files

- [Existing Tipoff page](assets/reference-tipoff-before.jpg)
- [Pick a Psych](assets/reference-pick-a-psych.jpg)
- [tzMiniFigs](assets/reference-tzminifigs.jpg)

These, `source/`, the manifest, the contact sheet, and handoff Markdown stay out of the final page’s media directory.
