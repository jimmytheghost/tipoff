# Website Copy and Layout

Version 0.1

Use this document when creating or revising website pages, portfolio entries, project galleries, landing pages, or interface copy for Jimmy. It records a recurring preference confirmed through website work.

Apply these website-specific defaults alongside `VOICE.md`. Choose factual descriptions for website copy; expressive or editorial voice guidance does not authorize adding personality to page headings, navigation, project summaries, or interface labels. Preserve Jimmy's supplied writing. A direct request for a different style or a redesign takes precedence.

Do not invent a brand voice, personality, or marketing campaign for Jimmy's website. Write straightforward descriptions of the projects and what they do. Jimmy's own writing may have personality; that does not authorize agents to manufacture more of it.

## Copy Rules

- Use project names as titles and factual labels for sections and links. Describe the problem, what was built, how it works, and relevant features in plain language.
- Do not add quippy headlines, slogans, taglines, inspirational quotes, rhetorical questions, jokes, snark, or statements intended to give a page "personality" or "character."
- Avoid invented first-person sentiments, motivations, anecdotes, and claims about Jimmy's feelings. Use first person only when grounded in his supplied writing or explicit direction.
- Avoid promotional filler, dramatic fragments, clever contrasts, and generic AI-written portfolio language. Do not turn a simple project description into a product launch pitch.
- Examples to avoid: "Things I wanted to exist. So I built them.", "A little record of a lot of work.", "Catch a little audio.", "The longer version.", and "One more thing." Use descriptive alternatives such as "Worklog", "Audio Recording", "Case Study", "How It Works", or "Features" when those labels are needed.
- Do not add introductory copy, a hero headline, decorative punctuation, numbered editorial sections, or an extra callout just to fill space. A gallery can simply show the projects.
- Preserve existing user-authored copy unless the requested task calls for editing it. Existing expressive wording is not a template for inventing new slogans.

## Layout Rules

- Before building or changing a page, inspect comparable pages in the target website and reuse their structure, typography, spacing, colors, image treatment, and navigation. Do not introduce a separate visual identity unless Jimmy explicitly requests a redesign.
- JimmyWeber.com gallery references: `/pages/other/` and `/pages/films/`. Use the existing `gallery gallery-3`, image tiles, and overlay labels where appropriate.
- JimmyWeber.com individual project references: `/pages/films/presence/`, `/pages/vfx/hoax/`, and `/pages/motion-gfx/nike/`. Reuse the existing featured imagery, `content-about-container`, `content-about`, and `nav-container` patterns.
- Do not replace these patterns with oversized marketing headings, custom card systems, tag pills, accent-color panels, or a landing-page layout merely because they are common elsewhere.
- For other websites, identify the equivalent local reference pages and components. For a new website, follow the requested design references and use factual copy unless Jimmy explicitly requests another voice. The JimmyWeber.com paths and CSS classes above are examples for that website, not required components for every project.
- Before delivering, check that every new sentence provides project information or necessary navigation, and that the page looks like part of this website. Remove copy whose only purpose is to sound clever or personable.

## Text-message and social link previews

Every user-facing page needs an intentional title-and-image link preview. Follow `LINK-PREVIEWS.md` for artwork, initial HTML metadata, packaging, and live checks. Reuse the page’s approved identity and factual labels; do not invent slogans or expose private page data in preview artwork.

## Importing Into a Project

Copy this file to `core/WEBSITE-COPY-AND-LAYOUT.md` in the website project, reference it from the local `AGENTS.md`, and record the import in `TOOLKIT_IMPORTS.md`. Keep the target site's specific reference pages and implementation details in its local instructions. Use the local copy during normal work.
