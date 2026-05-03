# Adaptive Cards

JSON card templates for use in Copilot Studio topics. These are data templates — bind them to Power FX variables in your topic YAML.

---

## Cards

### Interaction Cards

| File | Use case |
|------|---------|
| [`confirmation-card.json`](confirmation-card.json) | Ask the user to confirm or cancel an action (e.g. "Submit leave request?") |
| [`status-card.json`](status-card.json) | Display the result of an action or lookup (e.g. "Leave balance: 12 days") |
| [`form-card.json`](form-card.json) | Collect structured input from the user (e.g. date range, category, notes) |

### Feedback / CSAT Cards

| File | Use case | When to show |
|------|---------|-------------|
| [`feedback-thumbs.json`](feedback-thumbs.json) | 👍 / 👎 Yes or No — was this helpful? | End of every conversation (default) |
| [`feedback-rating.json`](feedback-rating.json) | ⭐ Star rating 1–5 | After thumbs-down, or after high-value topic completions |
| [`feedback-text.json`](feedback-text.json) | 💬 Free text + category dropdown | After rating ≤ 3 (optional — always has a Skip button) |

**To use all three in sequence:** add the `components/topics/feedback/` topic to your agent. It chains all three cards automatically with branching logic.

See `operations/user-feedback.md` for KPI targets, telemetry queries, and wiring instructions.

---

## How to use in Copilot Studio YAML

### Step 1 — Add the card JSON to your topic

In your topic YAML, use a `SendActivity` node with an `attachment` referencing the card:

```yaml
- kind: SendActivity
  id: sendConfirmCard_REPLACE
  activity:
    attachments:
      - contentType: application/vnd.microsoft.card.adaptive
        content:
          $schema: http://adaptivecards.io/schemas/adaptive-card.json
          type: AdaptiveCard
          version: "1.5"
          body:
            - type: TextBlock
              text: "Confirm your leave request"
              weight: Bolder
              size: Medium
            - type: FactSet
              facts:
                - title: From
                  value: =Text(Topic.StartDate, DateTimeFormat.ShortDate)
                - title: To
                  value: =Text(Topic.EndDate, DateTimeFormat.ShortDate)
                - title: Days
                  value: =Text(Topic.LeaveDays)
          actions:
            - type: Action.Submit
              title: Confirm
              data:
                action: confirm
              style: positive
            - type: Action.Submit
              title: Cancel
              data:
                action: cancel
```

### Step 2 — Capture the response

After the `SendActivity` node, add a `Question` node to wait for the card submit action:

```yaml
- kind: Question
  id: waitForCardResponse_REPLACE
  variable: Topic.CardResponse
  prompt: ""   # empty — the card above is the prompt
  entityType: UserEntireResponse
```

### Step 3 — Branch on the response

```yaml
- kind: ConditionGroup
  id: checkCardResponse_REPLACE
  conditions:
    - id: confirmBranch_REPLACE
      condition: =Topic.CardResponse.action = "confirm"
      actions:
        # proceed with action
    - id: cancelBranch_REPLACE
      condition: =Topic.CardResponse.action = "cancel"
      actions:
        - kind: SendActivity
          id: cancelMsg_REPLACE
          activity:
            text: No problem — I've cancelled that for you.
```

---

## Template Variables Reference

### confirmation-card.json

| Variable | Description | Example |
|----------|-------------|---------|
| `${title}` | Card heading | `"Confirm Leave Request"` |
| `${message}` | Supporting text | `"Please review the details below and confirm."` |
| `${details}` | Array of `{title, value}` facts | `[{"title":"From","value":"1 Jun"}]` |
| `${confirmLabel}` | Confirm button text | `"Yes, submit"` |
| `${cancelLabel}` | Cancel button text | `"Cancel"` |
| `${context}` | Passed back in submit data | Any string identifier |

### status-card.json

| Variable | Description | Example |
|----------|-------------|---------|
| `${title}` | Card heading | `"Leave Balance"` |
| `${statusLabel}` | Status text | `"12 days remaining"` |
| `${statusColor}` | Copilot color token | `"Good"`, `"Warning"`, `"Attention"` |
| `${statusIconUrl}` | Icon URL (optional) | SharePoint-hosted icon URL |
| `${details}` | Array of `{title, value}` facts | |
| `${footerNote}` | Small note at bottom | `"Resets 1 January"` |
| `${actionLabel}` | Link button text | `"View full calendar"` |
| `${actionUrl}` | Link button URL | SharePoint or web URL |

### form-card.json

| Variable | Description |
|----------|-------------|
| `${title}` | Card heading |
| `${subtitle}` | Optional subheading |
| `${field1Label}` / `${field1Placeholder}` | First text input |
| `${field2Label}` / `${showDateField}` | Date picker (shown when `showDateField = true`) |
| `${field3Label}` / `${field3Choices}` / `${showChoiceField}` | Dropdown (shown when `showChoiceField = true`) |
| `${showNotesField}` | Show/hide the free-text notes field |
| `${submitLabel}` | Submit button text |

---

## Channel Compatibility

| Channel | Adaptive Cards support |
|---------|----------------------|
| Microsoft Teams | Full support (v1.5) |
| Microsoft Copilot | Full support |
| Website (Power Pages) | Full support |
| SharePoint embedded | Full support |
| Classic Bot Framework Web Chat | v1.2 only — avoid v1.5 features |

Always test cards in the target channel — card rendering differs between channels.
