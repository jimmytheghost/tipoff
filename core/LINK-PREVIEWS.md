# Link previews for website pages

Version 0.1 — adopted November 1, 2026.

Every user-facing website page must have an intentional rich link preview when shared in a text message or social app: a readable page title and a relevant image, like a complete image card in Messages. A favicon-only bubble, broken thumbnail, or raw URL is not the intended result. This requirement applies to standalone apps, portfolio pages, and unlisted pages as well as pages using a shared site template. Preserve authentication, noindex rules, and discovery exclusions.

## Build the preview with the page

- Supply a page-specific title, concise factual description, canonical URL, and preview image in the initial server-rendered HTML `<head>`. Do not rely on JavaScript to create metadata or load an image for a crawler.
- Include `og:title`, `og:description`, `og:type`, `og:url`, `og:site_name`, and `og:image`; give the image its real MIME type, width, height, and descriptive `og:image:alt`. Use `twitter:card=summary_large_image` with matching title, description, image, and image alt metadata.
- Use absolute HTTPS URLs for the canonical page and image. Shortcuts must reach a real page whose metadata identifies the canonical destination. Avoid conflicting duplicate tags.
- Provide a real, deployable PNG or JPEG. A 1200 × 630 canvas is the default, not a guarantee about any client's crop. Keep the title and identifying artwork readable at phone-card size and inside safe margins. A favicon or SVG alone is insufficient as the preview image.
- Reuse approved project artwork, logo, type, and colors. A restrained title-and-artwork card is appropriate when there is no suitable image. No invented slogans, decorative copy, or unrelated stock imagery. Do not use screenshots containing personal measurements, records, credentials, or other private content. An unlisted page can use a neutral project-name image without exposing its data in a message preview.
- Include the image in the reproducible build/package allowlist and deployment file list. Preserve attribution/provenance and a reproducible source or generation script. Version image URLs when replacing an existing image that preview clients may have cached.
- Do not add public discovery or relax access controls just to obtain a rich preview. Authenticated pages may use a safe public sign-in preview; report client limitations honestly.

## Verify before calling it complete

1. Fetch the final page through its real canonical URL and each public shortcut. Check the returned HTML without executing JavaScript: correct title/description, one coherent metadata set, absolute image URL, expected redirect destination, and no fallback/error/challenge page.
2. Fetch the image from its actual public URL with a normal browser agent and a relevant preview-crawler agent. Verify successful HTTP status, image MIME type, actual decodable dimensions, and intended bytes/content. Check that crawler rules, hotlink protection, authentication, and edge challenges do not unexpectedly block it. Never bypass those protections or silently weaken them.
3. Visually inspect the actual image at full size and at phone-card size. Confirm artwork/title are readable and safe when cropped. Inspect metadata per route; a correct shared template does not establish coverage for standalone pages.
4. When Messages or another target client is available, inspect a freshly composed preview without sending a message. Sending requires Jimmy's explicit instruction. Existing messages and client caches may retain old previews; allow for refetching and report that behavior. If no client is available, record HTML/image verification and say the client render was not tested. Do not claim iMessage verification from a browser mockup.
5. Record canonical/alias URLs, image path, dimensions, provenance, actual checks, and any remaining client/caching limitation in the handoff. Include live metadata/image assertions in the release checks. A bare HTTP 200 is insufficient.

Apply this to new and changed pages as part of normal implementation. A sitewide claim requires an inventory and coverage report across the requested routes, including standalone apps; report unresolved gaps instead of assuming a shared include covers every page.

References: [Open Graph protocol](https://ogp.me/) and [Apple: Create rich previews for Messages](https://developer.apple.com/documentation/technotes/tn3156-create-rich-previews-for-messages). Client rendering remains controlled by the receiving app; metadata and accessible artwork establish eligibility, not a guaranteed identical card everywhere.
