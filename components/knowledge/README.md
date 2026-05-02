# Knowledge Source Components

Each folder is a knowledge source definition that connects your agent to a document repository or website.

## Available Knowledge Sources

| Component | Source type | What it does |
|-----------|-------------|-------------|
| [`sharepoint/`](sharepoint/) | SharePoint document library | Internal document search via Microsoft Search |
| [`public-website/`](public-website/) | Public URL (Bing) | Public website search via Bing |

## Usage Pattern

Knowledge sources are queried by the `knowledge-search` topic component (`components/topics/knowledge-search/`). Add the knowledge source first, then add the knowledge-search topic.

## How to add a knowledge source to your agent

1. Copy the component folder into your agent project
2. Replace `<SHAREPOINT_SITE_URL>` or `<PUBLIC_URL>` with the actual URL
3. Replace all `_REPLACE` suffixes
4. Add the `knowledge-search` topic if not already present
5. Push with `pac copilot push`

**Before adding:** Run the content audit (`project-delivery/06-content-audit.md`) to ensure the source content is ready.

Each component has its own README with specific setup instructions.
