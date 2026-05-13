# feedback-persisted — Persistent Feedback Collection

After every agent response, shows a single card (thumbs + star rating + open comment). On submit, writes the feedback — together with the user's question and cited sources — to a **SharePoint list** and a **Dataverse table**. Also fires a `Feedback.Persisted` telemetry event to App Insights.

---

## How it fits in

```
User sends a question
  └─ KnowledgeSearch fires (OnUnknownIntent)
       captures Global.FeedbackQuestion = user's message
       captures Global.FeedbackContext  = "Knowledge"

       ↓ generative AI produces answer

  └─ RemoveCitations fires (OnGeneratedResponse)
       captures Global.FeedbackSources  = raw response with [1][2] citation markers
       sends clean response to user
       calls → FeedbackPersisted

  └─ FeedbackPersisted
       shows feedback card (thumbs + stars + comment)
       writes row to SharePoint AgentFeedback list
       writes row to Dataverse mcs_agentfeedbacks table
       fires Feedback.Persisted to App Insights
```

For **structured topics** (PasswordReset, SubmitTicket, etc.): call `FeedbackPersisted` yourself at the end of each topic — see Step 8.

---

## What gets captured

| Field | Where it comes from | Notes |
|-------|---------------------|-------|
| Thumbs | Card input | `up` or `down` |
| Stars | Card input | 1–5; stored as 0 if user skipped the rating |
| Comment | Card input | Free text, max 500 chars |
| Question | `Global.FeedbackQuestion` | Set by KnowledgeSearch or your topic before calling BeginDialog |
| Context | `Global.FeedbackContext` | Topic name (e.g. `PasswordReset`) or `"Knowledge"` for generative answers |
| Cited Sources | `Global.FeedbackSources` | Raw AI response text with `[1][2]` markers; truncated to 3 800 chars |
| Conversation ID | `System.Conversation.Id` | Use to correlate with App Insights session logs |

> **Cited sources note:** The `[1][2]` markers in FeedbackSources refer to the knowledge documents configured in your agent (SharePoint, web, etc.). They identify *which* sources were cited but do not contain URLs — look up `[1]` against the knowledge source list in Copilot Studio.

> **Skip behaviour:** If the user clicks Skip, nothing is written to SharePoint or Dataverse. The telemetry event is also skipped.

---

## Prerequisites

Before starting:

- [ ] SharePoint site where you can create a list (site owner or edit permission)
- [ ] Dataverse environment where you can create a table (System Customizer or higher role)
- [ ] Agent already has `KnowledgeSearch` and `RemoveCitations` topics (for auto-wiring to knowledge answers)
- [ ] `shared_sharepointonline` connection available in your Power Platform environment
- [ ] `shared_commondataserviceforapps` connection available in your Power Platform environment

---

## Step 1 — Create the SharePoint list

1. Go to your SharePoint site → **New → List → Blank list**
2. Name: `AgentFeedback` → **Create**
3. Add the following columns. The **Title** column is already there — do not rename it.

| Column name | Type | Settings |
|-------------|------|---------|
| `Question` | Multiple lines of text | Plain text |
| `Thumbs` | Single line of text | — |
| `Stars` | Number | Min: 0, Max: 5, Decimal places: 0 |
| `Comment` | Multiple lines of text | Plain text |
| `CitedSources` | Multiple lines of text | Plain text |
| `ConversationId` | Single line of text | — |

> **Title** stores the `FeedbackContext` value (topic name or `"Knowledge"`). Do not add a separate Context column.

> **Column names are case-sensitive** in the YAML `item/<ColumnName>` parameters. Use exactly the names above, or update the YAML to match.

---

## Step 2 — Create the Dataverse table

1. Go to **make.powerapps.com → Tables → New table → Start from blank**
2. Set:
   - Display name: `Agent Feedback`
   - Plural name: `Agent Feedbacks`
   - Schema prefix: `mcs` (or your environment's default prefix)
3. Add these columns:

| Display name | Logical name | Type | Max length |
|--------------|-------------|------|-----------|
| Context | `mcs_context` | Text | 255 |
| Question | `mcs_question` | Multiline text | 4 000 |
| Thumbs | `mcs_thumbs` | Text | 10 |
| Stars | `mcs_stars` | Whole number | — |
| Comment | `mcs_comment` | Multiline text | 4 000 |
| Cited Sources | `mcs_citedsources` | Multiline text | 4 000 |
| Conversation ID | `mcs_conversationid` | Text | 100 |

4. **Save the table.**

> **Verify the plural logical name:** After saving, go to **Tables → Agent Feedback → Properties** and confirm **Name (plural)** shows `mcs_agentfeedbacks`. This is the value used in `entityName:` in the YAML. If your prefix differs, update the YAML accordingly.

---

## Step 3 — Add connections in Power Platform

Both connectors must be present in the environment where your agent lives.

1. Go to **make.powerapps.com → Connections → New connection**
2. Add **SharePoint** — sign in with a service account that has **Contribute** access to the `AgentFeedback` list
3. Add **Microsoft Dataverse** — sign in with a service account that has **Create** permission on the `mcs_agentfeedback` table

> Both actions use `mode: Caller` (agent's service identity). No per-user sign-in is required for feedback writes — users do not need SharePoint or Dataverse licences.

---

## Step 4 — Copy files into your agent

Replace `<schema>` with your agent's schemaName throughout.

```bash
# Mac / Linux
cp components/topics/feedback-persisted/FeedbackPersisted.topic.mcs.yml  agents/<schema>/topics/
cp components/topics/knowledge-search/KnowledgeSearch.topic.mcs.yml       agents/<schema>/topics/
cp components/topics/remove-citations/RemoveCitations.topic.mcs.yml       agents/<schema>/topics/

cp components/variables/feedback-context/FeedbackQuestion.variable.mcs.yml  agents/<schema>/variables/
cp components/variables/feedback-context/FeedbackContext.variable.mcs.yml   agents/<schema>/variables/
cp components/variables/feedback-context/FeedbackSources.variable.mcs.yml   agents/<schema>/variables/
```

```powershell
# Windows PowerShell
$a = "agents\<schema>"
Copy-Item components\topics\feedback-persisted\FeedbackPersisted.topic.mcs.yml  $a\topics\
Copy-Item components\topics\knowledge-search\KnowledgeSearch.topic.mcs.yml       $a\topics\
Copy-Item components\topics\remove-citations\RemoveCitations.topic.mcs.yml       $a\topics\

Copy-Item components\variables\feedback-context\FeedbackQuestion.variable.mcs.yml  $a\variables\
Copy-Item components\variables\feedback-context\FeedbackContext.variable.mcs.yml   $a\variables\
Copy-Item components\variables\feedback-context\FeedbackSources.variable.mcs.yml   $a\variables\
```

> **Cloud-First path (Clone Agent):** Topic files must be copied with rename — `.topic.mcs.yml` → `.mcs.yml`. See [troubleshooting/README.md → 2a](../../../troubleshooting/README.md#2a--duplicate-component-error-after-copying-template-files-into-a-cloned-folder).

---

## Step 5 — Replace placeholders

Open each file below and replace the marked values:

### `FeedbackPersisted.topic.mcs.yml`

| Placeholder | Replace with | Example |
|-------------|-------------|---------|
| `<SCHEMA>` | Your agent's schemaName | `it_helpdesk` |
| `<SP_SITE_URL>` | Full URL of the SharePoint site (not the list) | `https://contoso.sharepoint.com/sites/ITFeedback` |
| `AgentFeedback` | Your list name if you used a different name | `AgentFeedback` ← keep as-is if you used this name |
| `mcs_agentfeedbacks` | Dataverse table plural logical name | `mcs_agentfeedbacks` ← keep as-is if prefix is `mcs` |

### `RemoveCitations.topic.mcs.yml`

| Placeholder | Replace with |
|-------------|-------------|
| `<SCHEMA>` | Your agent's schemaName (line near bottom: `dialog: <SCHEMA>.topic.FeedbackPersisted`) |

### Variable files (`FeedbackQuestion`, `FeedbackContext`, `FeedbackSources`)

| Placeholder | Replace with |
|-------------|-------------|
| `<AGENT-SCHEMA-NAME>` | Your agent's schemaName (appears in `schemaName:` line of each file) |

---

## Step 6 — Run the ID replacement script

Replace all `_REPLACE` node IDs in the copied files:

```powershell
# Windows PowerShell — run from repo root
$schema = "it_helpdesk"   # ← your schemaName
$folder = "agents\$schema"

Get-ChildItem -Recurse -Filter "*.mcs.yml" -Path $folder | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    while ($content -match '_REPLACE\d*') {
        $id = -join ((97..122) + (48..57) | Get-Random -Count 6 | ForEach-Object {[char]$_})
        $content = [regex]::Replace($content, '_REPLACE\d*', "_$id", 1)
    }
    Set-Content $_.FullName $content
}
```

```bash
# Mac / Linux
SCHEMA="it_helpdesk"
find "agents/$SCHEMA" -name "*.mcs.yml" | while read f; do
  while grep -qE '_REPLACE[0-9]*' "$f"; do
    id=$(LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c6)
    sed -i "0,/_REPLACE[0-9]*/s/_REPLACE[0-9]*/_${id}/" "$f"
  done
done
```

---

## Step 7 — Knowledge answers wire-up

No extra work needed. `KnowledgeSearch` and `RemoveCitations` already include the feedback hooks. The `<SCHEMA>` replacement in Step 5 is all that is required.

What happens automatically:
1. `KnowledgeSearch` (fires on `OnUnknownIntent`) sets `Global.FeedbackQuestion` and `Global.FeedbackContext = "Knowledge"` before generative answering starts — this is the only point where `System.Activity.Text` is the user's message, not the AI's response.
2. `RemoveCitations` (fires on `OnGeneratedResponse`) captures `Global.FeedbackSources` from the raw AI response, sends the clean answer, then calls `FeedbackPersisted`.

---

## Step 8 — Wire to structured topics

For each custom topic (PasswordReset, SubmitTicket, VPNHelp, etc.) add these 4 nodes at the **end of the topic's action list**, just before `EndDialog`:

```yaml
      # ── Feedback ─────────────────────────────────────────────────────
      - kind: SetVariable
        id: setFeedbackCtx_REPLACE       # ← ID script replaces this
        variable: Global.FeedbackContext
        value: "PasswordReset"           # ← change to this topic's name

      - kind: SetVariable
        id: setFeedbackQ_REPLACE         # ← ID script replaces this
        variable: Global.FeedbackQuestion
        value: =Topic.UserInput          # ← the variable holding the user's main input in this topic

      - kind: SetVariable
        id: setFeedbackSrc_REPLACE       # ← ID script replaces this
        variable: Global.FeedbackSources
        value: ""                        # no citations for structured topics

      - kind: BeginDialog
        id: callFeedback_REPLACE         # ← ID script replaces this
        dialog: it_helpdesk.topic.FeedbackPersisted   # ← replace it_helpdesk with your schemaName
```

> **Topic.UserInput** is the variable name used in the scaffold and action-invoke templates. If your topic uses a different variable name for the user's input, change `=Topic.UserInput` to match.

> Run the ID script again after adding these nodes, or replace the four `_REPLACE` suffixes manually with any unique 6-char alphanumeric string.

---

## Step 9 — Verify before pushing

Check that no placeholders remain. Both commands must return **zero output**:

```powershell
# Windows — run from repo root
Get-ChildItem -Recurse -Filter "*.mcs.yml" -Path "agents\<schema>" | Select-String "<[A-Za-z]" | Select-Object Filename, LineNumber, Line
Get-ChildItem -Recurse -Filter "*.mcs.yml" -Path "agents\<schema>" | Select-String "_REPLACE" | Select-Object Filename, LineNumber, Line
```

```bash
# Mac / Linux
grep -rn "<[A-Za-z]" agents/<schema> --include="*.mcs.yml"
grep -rn "_REPLACE"   agents/<schema> --include="*.mcs.yml"
```

---

## Push and test

```
VS Code:  Ctrl+Shift+P → "Copilot Studio: Apply Changes"
```

Test the feedback flow:

| Test | Expected result |
|------|----------------|
| Ask a knowledge question, submit feedback | Row appears in SharePoint AgentFeedback list + Dataverse mcs_agentfeedbacks |
| Ask a knowledge question, click Skip | No row written anywhere |
| Submit a topic-wired structured topic | Row appears with correct Context (topic name), Sources = empty |
| Submit feedback with only thumbs, no stars or comment | Stars = 0, Comment = empty string in both stores |
| Check App Insights customEvents | `Feedback.Persisted` event present with correct thumbs and context values |

---

## Weekly triage views

### SharePoint list view (zero setup, available immediately)

1. Open the `AgentFeedback` list → **All Items ▾ → Create new view**
2. Name: `Weekly Triage`
3. **Filter:** `Created` is greater than or equal to `[Today]-7`
4. **Sort:** `Thumbs` Ascending (puts `down` first), then `Stars` Ascending (lowest first)
5. **Columns:** Title (Context), Question, Thumbs, Stars, Comment, Created

Each Monday morning: open this view → triage the thumbs-down rows → identify topics to improve.

---

### Power BI report (connect to Dataverse)

1. **Power BI Desktop → Get data → Dataverse**
2. Environment URL: your environment (e.g. `https://contosoit-dev.crm.dynamics.com`)
3. Select table: `mcs_agentfeedbacks` → Load

Build a one-page report with these visuals:

| Visual | Field / measure |
|--------|----------------|
| **Card — Total this week** | Count of rows where `mcs_createdon >= TODAY()-7` |
| **Card — Thumbs-down %** | `DIVIDE(COUNTIF(mcs_thumbs="down"), COUNT(mcs_thumbs)) * 100` |
| **Clustered bar — By topic** | X: `mcs_context`, Y: Count, Legend: `mcs_thumbs` |
| **Table — Triage list** | Filter: `mcs_thumbs = "down"` · Columns: Context, Question, Stars, Comment, Created |

Publish to Power BI service → **Scheduled refresh: Daily**.

---

## Telemetry

`Feedback.Persisted` fires on every submission (not on Skip):

```kusto
// App Insights — feedback summary by topic
customEvents
| where name == "Feedback.Persisted"
| extend thumbs   = tostring(customDimensions.thumbs)
| extend stars    = toint(customDimensions.stars)
| extend context  = tostring(customDimensions.context)
| summarize
    Responses  = count(),
    ThumbsDown = countif(thumbs == "down"),
    AvgStars   = round(avg(stars), 1)
  by context
| order by ThumbsDown desc
```

---

## Setup checklist

- [ ] SharePoint list `AgentFeedback` created with all 6 columns
- [ ] Dataverse table `mcs_agentfeedback` created with all 7 columns
- [ ] SharePoint connection added in environment (service account has Contribute on the list)
- [ ] Dataverse connection added in environment (service account has Create on the table)
- [ ] All 6 files copied into agent folder
- [ ] All `<PLACEHOLDER>` values replaced (Step 5)
- [ ] All `_REPLACE` IDs replaced (Step 6)
- [ ] Verify commands return zero output (Step 9)
- [ ] Structured topics wired (Step 8) — one snippet per topic
- [ ] Applied changes and tested all rows appear in both stores
- [ ] Weekly Triage list view created in SharePoint
