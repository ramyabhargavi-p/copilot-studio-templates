# Component: SharePoint Knowledge Source

Connects a SharePoint document library or folder as a searchable knowledge source.

## When to Use

Add this component when:
- The agent should answer questions from documents stored in SharePoint (policies, procedures, FAQs, manuals)
- Content is maintained by the team in SharePoint and should stay up to date in the agent automatically

## File

| File | Purpose |
|------|---------|
| `sharepoint.knowledge.mcs.yml` | KnowledgeSourceConfiguration pointing to a SharePoint path |

## What to Replace

| Placeholder | Replace with |
|-------------|-------------|
| `<Knowledge Source Name>` | Friendly name (e.g. `HR Policies`, `IT Runbooks`) |
| `site` URL | Your SharePoint document library or folder URL |

## URL Tips

- Use the most specific path you can — a folder within a library gives better retrieval than the whole site
- Encode spaces as `%20` in the URL
- Copy the URL directly from the SharePoint browser URL bar (use the base path, not a specific file)

**Examples:**
```
# Good — specific folder
https://contoso.sharepoint.com/sites/HR/Shared%20Documents/Policies

# Acceptable — full library
https://contoso.sharepoint.com/sites/HR/Shared%20Documents

# Avoid — entire site (too broad)
https://contoso.sharepoint.com/sites/HR
```

## Access Requirements

| Auth mode | Access requirement |
|-----------|------------------|
| `IntegratedAzureAD` / `ManualAzureAD` | The signed-in user must have read access to the SharePoint path |
| `None` | The agent's service principal must have read access (configure via SharePoint site permissions) |

## Using Multiple SharePoint Sources

Add one `.knowledge.mcs.yml` file per SharePoint path. To search only specific sources in a topic, use `SearchSpecificKnowledgeSources` in the [`knowledge-search`](../../topics/knowledge-search/) component.

## Gotchas

- The knowledge source indexes documents, not metadata. Content inside PDFs, Word docs, and PowerPoint files is indexed; list column values are not
- Changes to SharePoint documents are reflected in the agent after the next sync (can take up to 24 hours)
- Password-protected documents are not indexed
