# Tipoff

Read [Jimmy Weber’s Agentic Toolkit](https://github.com/jimmytheghost/agentic-toolkit/blob/main/README.md) on GitHub for shared guidance relevant to the task. The private toolkit requires authenticated access. If it is unavailable, say what you could not read and continue with the project instructions where possible.

Native NBA/NFL/WNBA/NHL/MLB viewing guide for macOS 15+ (SwiftUI menu bar app, part of the Bug / Worklog suite) and Windows 10/11 x64 (C# / WPF system-tray app).

- Keep the 360-point width, mint accent, system typography, and subtle rounded cards.
- No scores, standings, game clocks, or live-game telemetry. The model and persisted cache must exclude them.
- Use source-provided broadcasters. Never infer streaming availability, local rights, or League Pass eligibility.
- Preserve working cached data on network/schema errors. Show source, freshness, and fallback limitations honestly.
- Follow the computer’s time zone and use calendar days rather than fixed 24-hour offsets.
- NFL uses ESPN; identify the source and put Denver first on NFL days. Top-level guides represent sports (NBA, NFL, WNBA, NHL, MLB); the Broncos belong within NFL. Never infer local affiliate or streaming access.
- Prefer Avalanche games within NHL and Rockies games within MLB, including league and ESPN fallback identities. Apply priority to saved snapshots without changing their contents or freshness.
- WNBA uses ESPN; NHL and MLB use league schedules with ESPN fallback. Keep source labels, explicit fallback labels, and isolated sport/date/time-zone caches. Do not show routine coverage disclaimers in the compact UI.
- Nuggets games have a personal Altitude schedule supplement. Require date/opponent/home-away/tipoff agreement; preserve regional footnotes and original freshness when using saved data.
- Do not modify sibling projects.
- Validate with `scripts/test.sh`, `scripts/package-app.sh`, and a live `TipoffCheck` when networking/source code changes. Record the actual executed test count.
- Public website sources are undocumented. Keep fixtures and malformed/schema-change cases in decoder tests.
- Keep README, docs/PLAN.md, and docs/VALIDATION.md synchronized with implemented behavior and actual evidence.
- For a current-user Windows installation, use `scripts/install-windows.ps1`; it packages to `%LOCALAPPDATA%\Programs\Tipoff`, creates a Start Menu shortcut, and launches the app so its Start with Windows registration uses a stable path. The GitHub `v0.2.0` release is an older macOS-only NBA build, not the current Windows app.

## GitHub delivery

- The repository is public at `https://github.com/jimmytheghost/tipoff`. It is an MIT-licensed personal tool shared as-is; keep that framing in documentation. Do not promise product support or a release cadence.
- After each completed change, run relevant validation, update affected documentation, commit, and push the current branch before reporting completion. Preserve unrelated work and report commit or push failures.
- Keep generated builds, local caches, credentials, and user data out of Git. Documentation-only changes need diff/content checks rather than an app rebuild.

## JimmyWeber.com

For work on the browser guide, read the toolkit’s [website publishing](https://github.com/jimmytheghost/agentic-toolkit/blob/main/core/WEBSITE-PUBLISHING.md), [website copy and layout](https://github.com/jimmytheghost/agentic-toolkit/blob/main/core/WEBSITE-COPY-AND-LAYOUT.md), and [link previews](https://github.com/jimmytheghost/agentic-toolkit/blob/main/core/LINK-PREVIEWS.md) guides. Maintain [the website handoff](WEBSITE-HANDOFF.md).
