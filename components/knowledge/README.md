# Knowledge Source Components

3 knowledge source templates. Copy one per knowledge source your agent answers questions from.

---

## Knowledge Sources

| Folder | Source type | Use when… |
|--------|------------|-----------|
| [`sharepoint/`](sharepoint/) | SharePoint library | Internal documents, policies, FAQs stored in SharePoint |
| [`public-website/`](public-website/) | Public URL | Publicly accessible websites or documentation |
| [`glossary/`](glossary/) | Dataverse (CSV) | Customer-specific acronym or term glossary; loaded on demand |

---

## Usage

```bash
cp components/knowledge/sharepoint/sharepoint.knowledge.mcs.yml \
   agents/<your-agent>/knowledge/<SourceName>.knowledge.mcs.yml
```

One file per knowledge source. The agent combines answers from all sources unless you set `triggerCondition: false` (glossary pattern — loaded explicitly by `conversation-init`).

→ How knowledge search works end-to-end: [`../topics/knowledge-search/README.md`](../topics/knowledge-search/README.md)
