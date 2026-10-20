# Tipoff

Native SwiftUI macOS 15+ NBA viewing guide, part of the Bug / Worklog menu bar suite.

- Keep the 360-point width, mint accent, system typography, and subtle rounded cards.
- No scores, standings, game clocks, or live-game telemetry. The model and persisted cache must exclude them.
- Use source-provided broadcasters. Never infer streaming availability, local rights, or League Pass eligibility.
- Preserve working cached data on network/schema errors. Show source, freshness, and fallback limitations honestly.
- Follow the Mac’s time zone and use calendar days rather than fixed 24-hour offsets.
- Nuggets games have a personal Altitude schedule supplement. Require date/opponent/home-away/tipoff agreement; preserve regional footnotes and original freshness when using saved data.
- Do not modify sibling projects.
- Validate with `scripts/test.sh`, `scripts/package-app.sh`, and a live `TipoffCheck` when networking/source code changes. Record the actual executed test count.
- Public website sources are undocumented. Keep fixtures and malformed/schema-change cases in decoder tests.
- Keep README, docs/PLAN.md, and docs/VALIDATION.md synchronized with implemented behavior and actual evidence.

## GitHub delivery

- The repository is private at `https://github.com/jimmytheghost/tipoff`; preserve that visibility.
- After each completed change, run relevant validation, update affected documentation, commit, and push the current branch before reporting completion. Preserve unrelated work and report commit or push failures.
- Keep generated builds, local caches, credentials, and user data out of Git. Documentation-only changes need diff/content checks rather than an app rebuild.
