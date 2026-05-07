# SharePoint Knowledge Source

**Source type:** SharePoint document library

Enables generative answers from internal SharePoint documents, policies, and FAQs.

## Files

| File | Purpose |
|------|---------|
| `sharepoint.knowledge.mcs.yml` | Template — configure site URL and library path |

## Quick start

```bash
cp components/knowledge/sharepoint/sharepoint.knowledge.mcs.yml \
   agents/<your-agent>/knowledge/<SourceName>.knowledge.mcs.yml
```

Replace `<SHAREPOINT_SITE_URL>` and `<LIBRARY_PATH>` with your SharePoint library details.

**Requirement:** The Power Platform SharePoint connection must be authenticated with an account that has read access to the library.

→ Knowledge search topic that queries this source: [`../../topics/knowledge-search/README.md`](../../topics/knowledge-search/README.md)
