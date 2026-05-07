# Public Website Knowledge Source

**Source type:** Public URL

Enables generative answers from any publicly accessible website or documentation site.

## Files

| File | Purpose |
|------|---------|
| `public-website.knowledge.mcs.yml` | Template — configure the public URL to crawl |

## Quick start

```bash
cp components/knowledge/public-website/public-website.knowledge.mcs.yml \
   agents/<your-agent>/knowledge/<SourceName>.knowledge.mcs.yml
```

Replace `<PUBLIC_URL>` with the URL of the website to crawl (e.g., `https://docs.contoso.com`).

**Note:** Only use for publicly accessible URLs. For internal content, use the SharePoint knowledge source instead.
