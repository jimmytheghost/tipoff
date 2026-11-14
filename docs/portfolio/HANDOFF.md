# Tipoff portfolio expansion handoff

This content and asset package was prepared November 7, 2026 from source baseline `a1ea842`. The [expanded portfolio page](https://www.jimmyweber.com/pages/projects/tipoff/) was subsequently published. The [website handoff](../../WEBSITE-HANDOFF.md#portfolio-expansion-published--november-7-2026) records the deployed scope, artwork, and verification.

## Start here

Read [PAGE-COPY.md](PAGE-COPY.md), [ASSETS.md](ASSETS.md), and the existing [website handoff](../../WEBSITE-HANDOFF.md). The copy is ready to place; HTML comments are instructions and must not appear on the published page. [CONTACT-SHEET.jpg](CONTACT-SHEET.jpg) provides a quick asset review. [asset-manifest.json](asset-manifest.json) records image sizes, hashes, captions, alt text, and provenance.

Target: https://www.jimmyweber.com/pages/projects/tipoff/

Browser app: https://www.jimmyweber.com/tipoff

Source/install instructions: https://github.com/jimmytheghost/tipoff

## What the references establish

Reviewed the live Tipoff, [tzMiniFigs](https://www.jimmyweber.com/pages/art/nft/tzminifigs/), and [Pick a Psych](https://www.jimmyweber.com/pages/projects/pick-a-psych/) pages. Full-page captures are included for editorial reference only. Both reference pages pair a short personal introduction with descriptive feature/process sections, inline images, specific captions, and on-page anchors. Pick a Psych is the closer software-page model: real interface images illustrate individual behaviors, followed by implementation and access information. tzMiniFigs demonstrates how to explain the work and keep original artifacts distinct from reconstructions. Apply that editorial depth proportionately; Tipoff does not need the NFT page’s length or gallery density.

The website agent owns final layout, shared templates, responsive integration, and deployment. Use the website workspace’s current instructions and existing components. Do not copy the app’s mint/lime surfaces into a new portfolio-page theme or build a separate landing page. Use factual section names and the existing image enlargement/caption treatment. Platform screenshots need readable presentation and access to the original image, rather than three tiny panels in a decorative grid.

## Proposed reading order and image placement

| Order | Section / anchor | Content and evidence |
| --- | --- | --- |
| 1 | Tipoff / introduction | Overview image or a strong actual guide capture; short summary; View the schedule and Source code and installation links. Optional factual line: SwiftUI · C# / WPF · HTML / CSS / JavaScript / PHP. |
| 2 | Why I made it / `why` | Preserve the exact existing opening, Alec Miller video and credit, README motivation, and existing closing sentence. |
| 3 | The macOS menu bar app / `macos` | Dark and light native renders; explain compact guide and native integration. |
| 4 | The Windows system-tray app / `windows` | Dedicated platform copy and labeled feature diagram; replace/add real Windows captures when available. |
| 5 | The browser guide / `web` | Desktop national guide; phone guide and calendar; optional full schedule view to show filters. |
| 6 | Colorado teams and Altitude / `altitude` | Native Altitude details and/or browser expanded Nuggets card; concrete matching and regional-note behavior. |
| 7 | Where the listings come from / `sources` | Plain-language source hierarchy, cache/freshness behavior, and short implementation explanation. Browser status capture supports this section. |
| 8 | Source and installation / `installation` | Current source vs older download, MIT/as-is framing, repository and browser links; existing portfolio navigation. |

On-page links can focus on macOS, Windows, Browser guide, and Sources. Keep the existing primary title Tipoff. No need for a feature checklist, invented development milestones, metrics, testimonials, or a download CTA that implies current packaged binaries exist.

## Preserve the motivation and video

The live page’s existing opening is: “It has never been harder to watch sports. Alec Miller's Instagram sketch describes it perfectly.” Its closing is: “So now watching sports isn't such a pain in the ass.” Both are retained verbatim in PAGE-COPY.md. The first-person motivation between them comes verbatim from the repository README, not invented biography. New descriptive copy is factual third person.

Keep these existing deployed assets; do not re-encode or replace them:

- Video: `/assets/videos/projects/tipoff/alec-miller-sports-sketch.mp4`, MIME `video/mp4`.
- Poster: `/assets/videos/projects/tipoff/alec-miller-sports-sketch.jpg`.
- Existing native video controls and accessible description: “Alec Miller's sketch about watching sports”.
- Credit/link: `@alec.miller`, https://www.instagram.com/alec.miller/ . Keep it visibly associated with the video. No claim of video authorship by Jimmy.

The video is not bundled again; these paths were read from the live page’s video element. Preserve any current captions/transcript or consent behavior the website workspace has added since this capture. Playback/audio were not tested during this content task.

## Asset truth and remaining Windows capture

Browser files are actual public-page screenshots with unaltered listing content. Native macOS images are offscreen AppKit/SwiftUI renders of production views, not captures of a clicked menu-bar popover. They use a source-fetched November 7 NBA snapshot; original timestamps remain in the source file. Their relative freshness label reflects render time and is historical artwork, not current availability.

No accessible Windows desktop was available in this task. `windows-feature-diagram.png` is complete usable explanatory imagery and prominently says it is a feature diagram, not a Windows screenshot. Do not relabel it, a macOS render, or generated UI as a real WPF capture. If it is used on the page, retain the diagram label in both the image and caption. A real Windows screenshot is the one optional asset upgrade outstanding; see ASSETS.md for a concrete capture brief. Current Windows behavior was checked against README and WPF source; no new Windows execution/installation is claimed.

Existing branding remains available at `img/Tipoff.png`, `img/Tipoff-transparent.png`, and `web/brand-mark.png`. The pre-existing untracked `img/Tipoff-banner.png` was left untouched and is not part of this delivery. Browser screenshots contain third-party team/network marks as displayed by Tipoff; they do not imply affiliation or endorsement. Do not extract these marks to create an unrelated branding system. See NOTICE and the main handoff for source details.

## Link preview proposal

Use the supplied `assets/tipoff-social-v1.png` (1200 × 630 PNG). It reuses existing project identity and actual macOS/browser imagery, with the project title and factual platform labels. Generation source is included. Suggested metadata:

- Title: `Tipoff | JimmyWeber.com`
- Description: `A personal sports viewing guide for macOS, Windows, and the web, with local game times and source-listed broadcasters across five leagues.`
- Canonical / og:url: `https://www.jimmyweber.com/pages/projects/tipoff/`
- Proposed image destination: `https://www.jimmyweber.com/assets/img/projects/tipoff/tipoff-social-v1.png` (not uploaded yet).
- og:image:type `image/png`, width `1200`, height `630`; alt: `Tipoff app icon with macOS and browser viewing-guide images.`
- og:type `website`, og:site_name `JimmyWeber.com`; twitter:card `summary_large_image` with matching title, description, image, and image alt.

Use the site’s server-rendered metadata path; avoid duplicates. Keep portfolio and hosted-guide canonicals distinct. This package does not replace the browser app’s existing metadata. Live preview/image/crawler/redirect and Messages checks belong to integration; none is claimed for the proposed image URL.

## Review and integration checklist

1. Confirm the latest source facts and website guidance. Retain the motivation, video source/poster, and credit. Preserve current portfolio navigation.
2. Copy only selected page-ready assets from ASSETS.md to the existing project media directory, plus the social PNG. Do not publish reference captures, snapshots, manifest, scripts, or this handoff as page assets. Use image intrinsic dimensions, responsive sizing, meaningful alt text, and existing enlargement behavior. Keep screenshot text readable; lazy-load below-fold images.
3. Check links to `/tipoff` and the public repository. Present current-source installation separately from the legacy v0.2.0 download. Use “menu bar” for macOS and “system tray” or “notification area” for Windows. No unsupported access/rights promises or visitor favorites customization.
4. Verify desktop/phone layouts and keyboard navigation, image loads, video controls/credit, anchor targets, PHP syntax and relevant site checks. Inspect preview artwork at full and phone size; fetch final metadata and image with browser/crawler agents after deployment. Follow the website’s actual publication authorization and deployment process.
5. Record final URLs, shipped asset list, executed checks, release/rollback evidence, and any Windows capture replacement in the website workspace and Tipoff handoff. The present task does not authorize an immediate production change.

## Pasteable instruction for the website agent

> Expand the existing Tipoff portfolio page using `docs/portfolio/HANDOFF.md`, `PAGE-COPY.md`, and `ASSETS.md` from the Tipoff repository. Follow the editorial depth of tzMiniFigs and Pick a Psych using the website’s existing design. Preserve the existing Alec Miller video, its credit, and Jimmy’s supplied motivation. Give the macOS menu bar app, Windows tray app, and browser guide their own illustrated sections. Use the supplied real browser captures and labeled native renders; the Windows feature diagram must remain labeled as an illustration unless replaced with an actual Windows capture. Verify the current-source/legacy-download distinction and all links. Prepare and verify the page in the website workspace; use the website’s authorized publication process for any deployment.
