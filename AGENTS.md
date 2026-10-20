# Tipoff

Native SwiftUI macOS 15+ NBA viewing guide, part of the Bug / Worklog menu bar suite.

- Keep the 360-point width, mint accent, system typography, and subtle rounded cards.
- No scores, standings, game clocks, or live-game telemetry. The model and persisted cache must exclude them.
- Use source-provided broadcasters. Never infer streaming availability, local rights, or League Pass eligibility.
- Preserve working cached data on network/schema errors. Show source, freshness, and fallback limitations honestly.
- Follow the Mac’s time zone and use calendar days rather than fixed 24-hour offsets.
- Do not modify sibling projects.
- Validate with `scripts/test.sh`, `scripts/package-app.sh`, and a live `TipoffCheck` when networking/source code changes. Record the actual executed test count.
- Public website sources are undocumented. Keep fixtures and malformed/schema-change cases in decoder tests.
- Keep README, docs/PLAN.md, and docs/VALIDATION.md synchronized with implemented behavior and actual evidence.
