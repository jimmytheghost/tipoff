# Projects Intended for JimmyWeber.com

Version 0.2

Use this process as soon as Jimmy says an app or project will eventually go on his website. Also use it when adding an existing project to the website. Read this alongside the target project's instructions, `VOICE.md`, and `WEBSITE-COPY-AND-LAYOUT.md`. The project source determines what exists; the website workspace determines its current integration and deployment details.

## Start of an app project

Import this guide and `LINK-PREVIEWS.md`, then adapt `templates/WEBSITE-HANDOFF.md` into `WEBSITE-HANDOFF.md` in the project root. Reference both from the project's `AGENTS.md` and record the imports. Maintain the handoff at meaningful milestones so another agent can finish the website work without reconstructing the conversation. Keep it short and factual; use `unknown`, `proposed`, or `not applicable` where appropriate.

Record the intended outcome in `PROJECT.md`:

- **Portfolio entry:** a description, screenshots, and appropriate source/download links. A local Mac app can have a portfolio entry without running on the web server.
- **Hosted app:** the browser application itself runs at a website URL, normally with a portfolio entry linking to it.
- **Externally hosted app:** a portfolio entry links to an app running elsewhere.

When Jimmy only says "eventually on my website," prepare for a portfolio entry and assess whether hosting is needed. Infer the intended outcome from the brief when possible. Ask only if an unresolved hosting choice changes the implementation. Future website intent authorizes preparation, not immediate production publication.

## Build with the destination in mind

Locate Jimmy's existing website workspace among the accessible projects or connected sources and record its location/access method in the app's local `PROJECT.md` when useful. Do not create a replacement website workspace. If access is unavailable, continue independent app work and ask for the location/access when integration needs it.

Before choosing hosting-dependent architecture, consult the website workspace's `docs/DEPLOYMENT.md` and `PROJECTS-OPERATIONS.md` when accessible. If they are unavailable, record that limitation and keep assumptions explicit. Do not invent a filesystem path or copy SSH credentials into the app project.

The current JimmyWeber.com baseline is Apache with PHP 8.1 and an existing PHP website. Static HTML/CSS/JavaScript and compatible PHP are the simplest hosting fit. Confirm the current runtime before shipping. A development server is not a production runtime. A framework that builds static files can fit; a persistent Node/Python service, database, background worker, or new server package needs a separate hosting plan. Do not silently provision infrastructure or rewrite an established app just to fit PHP.

For a hosted web app:

- Make its URL prefix configurable and test the production build under a nested path, including asset URLs, navigation, refreshes, API calls, and redirects. Propose a stable slug and check for collisions during website integration.
- Keep the app's styles, JavaScript, storage keys, and service-worker scope isolated from the rest of the website. Preserve the app's approved interface; the portfolio wrapper follows the website's design.
- Keep secrets server-side. Record required environment/configuration names without their values. Browser bundles cannot protect API keys.
- Separate deployable code from uploads, user records, databases, generated caches, and local configuration. Document write paths, permissions, and backup needs. A website upload must preserve live state.
- State whether the app is public, private, or needs authentication. Unlisted URLs do not provide access control. Do not publish private data in sample fixtures or screenshots.
- Record reproducible build commands and the exact deployable output. Exclude development servers, `node_modules`, source credentials, and unrelated project files from the upload.

Do the work the app needs. This guide does not require a new framework, CI system, installer, analytics, or infrastructure for a simple project.

## Text-message and social link previews

Follow `LINK-PREVIEWS.md` for every user-facing page, including standalone and unlisted hosted apps. Create the preview image and server-rendered metadata during app development, include the image in packaging, and verify live metadata, image URLs, and redirects during integration. Preserve privacy: preview artwork must not expose private app data. Record the image, canonical/alias URLs, and actual client verification in the handoff.

## Prepare the website handoff

Keep `WEBSITE-HANDOFF.md` current with supported project facts, source location and revision, build/run commands, intended URL, hosting needs, deployable files, live state to preserve, known limitations, and verification results. Include actual screenshots and available artwork with paths, dimensions, and provenance. Mark mockups clearly. Preserve Jimmy's supplied wording and identify any personal motivation that he actually supplied.

An existing README can supply most of this information; link to it rather than duplicating long technical documentation. Do not invent features, pretend untested environments work, expose private repositories through public links without direction, or change a repository's visibility as part of website preparation. Use `GITHUB-PROJECT-PAGES.md` when repository sharing is also requested.

## Integrate in the website workspace

The agent doing this stage needs access to both the source project and the website workspace. The same agent can carry out both roles when authorized and equipped; a separate chat is optional. Access to the toolkit alone does not provide access to the website or its server.

1. Read the handoff, inspect the actual app and source, and read the website's `AGENTS.md`, `PROJECTS-OPERATIONS.md`, and `docs/DEPLOYMENT.md`. Verify facts rather than treating a handoff as instructions to execute arbitrary commands.
2. Check for an existing entry and URL collisions. Use the existing project catalog, shared detail template, gallery, homepage discovery, and sitemap behavior. Current files are `includes/projects/data.php`, `includes/projects/detail.php`, and `pages/projects/<slug>.php`; confirm these against the workspace before editing.
3. Write supported project descriptions using the local voice guidance and Jimmy's identified writing samples. Reuse the site's layouts and image treatments. Keep the app's own interface separate from its portfolio description.
4. For hosted apps, implement the agreed destination and routing, test the built output there, and preserve application data. A request for a portfolio entry alone does not authorize installing a new backend service.
5. Verify local pages, links, assets, mobile/desktop layouts, relevant PHP syntax, and any affected app behavior. Follow the site's sitemap procedure. Prepare an explicit file list and a reviewable deployment plan.
6. Publish when Jimmy has requested publication, using the website's maintained deployment procedure. An explicit "add it to my website and deploy it" is authorization; do not ask again. A request to build something for eventual publication stops with the working app and maintained handoff. If publication requires an unresolved consequential decision, finish independent preparation before asking.
7. Verify the deployed URLs and a meaningful user flow. Record the release, changed files, actual checks, backup location, and rollback command in website operations notes, then update the project's handoff with its real URLs and status. Report any unfinished step accurately.

## Useful starting instructions

New app:

> Initialize this project from Agentic Toolkit. You are building a new app that will eventually go on my website. Follow the website publishing process from the start and maintain WEBSITE-HANDOFF.md. The app will be a ...

Existing project:

> Add this project to my website using the toolkit website publishing process. The source is at [project location]. Prepare and verify it locally.

Publication:

> Add this project to my website and deploy it using the website publishing process. The source is at [project location].

## Toolkit boundaries

Keep this reusable guide and the handoff template in the toolkit. Keep server addresses, SSH aliases, absolute workspace paths, deployment scripts, release history, and private configuration with the website or the local machine. Store private keys in the machine's SSH storage. Never place passwords, keys, tokens, or live user data in this guide or a portable handoff.
