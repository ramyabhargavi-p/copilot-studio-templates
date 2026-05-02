# Content Audit

Assess the quality and readiness of your knowledge source content before building. Poor content = poor answers. No amount of prompt engineering fixes a bad knowledge base.

Run this before Phase 3 (Build) — ideally during Design.

---

## What is a Content Audit?

A content audit reviews the documents, pages, and files you plan to use as knowledge sources. It answers:

- Is the content accurate and up to date?
- Is it written in a way an AI can search and summarise?
- Does it actually cover the questions users will ask?
- Is it scoped correctly — not too broad, not missing anything?

---

## Content Inventory

List every document or source you plan to use. Fill in one row per file or page.

| # | Document / Page | Location (URL or path) | Last updated | Owner | Covers topics | Readable? | Approved for AI use? |
|---|-----------------|------------------------|--------------|-------|---------------|-----------|---------------------|
| 1 | | | | | | ☐ | ☐ |
| 2 | | | | | | ☐ | ☐ |
| 3 | | | | | | ☐ | ☐ |

**Readable?** — Can a human read and understand it without needing additional context?
**Approved for AI use?** — Has the document owner confirmed it can be surfaced via an AI agent?

---

## Content Quality Assessment

For each document in the inventory, rate it against these criteria:

### Currency
| Rating | Description |
|--------|-------------|
| ✅ Current | Updated within the last 6 months; no known inaccuracies |
| ⚠️ Stale | Updated 6–18 months ago; may have minor gaps |
| ❌ Outdated | Older than 18 months or known to be inaccurate |

**Action for ❌:** Update before adding to the knowledge source. An AI will confidently answer questions based on outdated content.

### Clarity
| Rating | Description |
|--------|-------------|
| ✅ Clear | Written in plain language; no unexplained jargon |
| ⚠️ Jargon-heavy | Contains acronyms or internal terms that users may not know |
| ❌ Unclear | Structured in a way that makes it hard to extract facts (e.g. dense legal prose, complex tables) |

**Action for ❌:** Rewrite the relevant sections in plain language, or create a separate FAQ document.

### Coverage
| Rating | Description |
|--------|-------------|
| ✅ Complete | Answers the questions in your eval CSV |
| ⚠️ Partial | Covers most topics but has gaps |
| ❌ Insufficient | Doesn't cover the questions users will ask |

**Action for ❌:** Identify the gaps and create new content to fill them.

---

## Coverage Gap Analysis

List every question type users might ask the agent. Map each to a document.

| User question | Covered by document # | Gap? |
|---------------|----------------------|------|
| | | ☐ |
| | | ☐ |
| | | ☐ |

Use the eval CSV generator prompt (`prompts/ai-prompts/generate-eval-cases.md`) to produce a comprehensive question list.

---

## Content Preparation Checklist

Before adding documents to the knowledge source:

| # | Check | Notes |
|---|-------|-------|
| CP1 | All documents checked in (not draft) in SharePoint | |
| CP2 | No password-protected PDFs | |
| CP3 | Tables are formatted simply — nested tables removed or flattened | |
| CP4 | Images that contain text have been replaced with text equivalents | |
| CP5 | Documents with confidential sections have been split — confidential content in a separate, non-indexed library | |
| CP6 | File names are descriptive (e.g. `Annual-Leave-Policy-2024.docx`, not `Document123.docx`) | |
| CP7 | Large documents (>50 pages) have been split into topic-specific documents | |
| CP8 | Duplicate content removed — one source of truth per topic | |

---

## Recommended Knowledge Source Structure (SharePoint)

```
/Copilot Knowledge Sources/
    /<Agent Name>/
        Policies/           ← formal policy documents
        Procedures/         ← how-to guides
        FAQs/               ← FAQ pages (highest retrieval quality)
        Reference/          ← tables, lists, contacts
```

Keep each subfolder narrowly scoped. The agent indexes by site/library — the narrower the library, the more relevant the search results.

---

## Sign-Off

| Item | Confirmed by | Date |
|------|-------------|------|
| All documents reviewed and rated | | |
| All ❌ items remediated or excluded | | |
| Coverage gaps addressed | | |
| Content preparation checklist complete | | |
| Knowledge source structure set up in SharePoint | | |
