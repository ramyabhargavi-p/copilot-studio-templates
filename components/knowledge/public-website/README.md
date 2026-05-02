# Component: Public Website Knowledge Source

Uses a publicly accessible website as a knowledge source, powered by Bing search.

## When to Use

Add this component when:
- The agent should answer questions from a public website (product docs, public-facing help centre, external standards)
- The content is publicly indexed by Bing

Do **not** use for:
- Internal/intranet sites not accessible by Bing
- Sites behind authentication (use SharePoint knowledge source instead)
- Highly dynamic or frequently changing content (Bing indexing lag can cause stale answers)

## File

| File | Purpose |
|------|---------|
| `public-website.knowledge.mcs.yml` | KnowledgeSourceConfiguration pointing to a public URL |

## What to Replace

| Placeholder | Replace with |
|-------------|-------------|
| `<Knowledge Source Name>` | Friendly name (e.g. `Product Documentation`, `Microsoft Learn`) |
| `site` URL | Your public website URL |

## URL Depth Rules

Bing searches within the scope of the URL you provide, up to **2 levels deep** beyond the domain:

| URL | Depth | Works? |
|-----|-------|--------|
| `https://example.com/docs` | +1 | Yes |
| `https://example.com/docs/api` | +2 | Yes |
| `https://example.com/docs/api/v2` | +3 | No — ignored |

If your content is more than 2 levels deep, use the closest parent path that keeps depth ≤ 2.

## How Bing Search Works

- **Not a full crawl** — Bing searches its existing index of the site, it doesn't crawl on demand
- **Snippet-based** — returns excerpts, not full page content
- **No authentication** — only publicly accessible pages are findable

## Gotchas

- If the site isn't indexed by Bing yet (new site, recently launched content), the knowledge source may return no results
- Search quality depends on Bing's index of the site — pages with poor SEO may not surface well
- The agent does not check for broken links or removed pages; Bing may still return snippets from cached/removed content
