# AI Prompt: Generate Adaptive Card JSON

Use this prompt to generate Adaptive Card JSON for use in Copilot Studio topics.

---

## Full Card Generator

```
You are a Microsoft Adaptive Cards specialist. Generate Adaptive Card JSON (schema version 1.5) 
for use in a Copilot Studio agent running in Microsoft Teams.

Requirements:
- Schema version 1.5
- Mobile-friendly: wrap all text, no fixed widths
- Use FactSet for structured data (not tables)
- Include Action.Submit buttons (not Action.Http) — Copilot Studio reads the submit data
- Add $when conditions so optional sections hide cleanly when data is empty
- Do not use features only available in schema 1.6+

Card purpose:
[DESCRIBE WHAT THE CARD SHOULD SHOW AND DO]

Data available from the conversation:
[LIST THE VARIABLES OR DATA FIELDS AVAILABLE, e.g.:
- Topic.EmployeeName (text)
- Topic.LeaveStartDate (date)
- Topic.LeaveEndDate (date)
- Topic.LeaveDays (number)
]

Actions the user can take:
[LIST THE BUTTONS, e.g.:
- Confirm (positive style, submit data: {action: "confirm"})
- Cancel (destructive style, submit data: {action: "cancel"})
]
```

---

## Example Input

```
Card purpose:
Confirm a leave request before submitting it to the HR system.
Show the employee the key details and ask them to confirm or cancel.

Data available:
- Topic.EmployeeName (text) — the signed-in user's display name
- Topic.LeaveStartDate (date)
- Topic.LeaveEndDate (date)
- Topic.LeaveDays (number)
- Topic.LeaveType (text, e.g. "Annual Leave")

Actions:
- Yes, submit (positive, data: {action: "confirm"})
- No, go back (default, data: {action: "cancel"})
```

## Example Output

```json
{
  "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
  "type": "AdaptiveCard",
  "version": "1.5",
  "body": [
    {
      "type": "TextBlock",
      "text": "Confirm Leave Request",
      "weight": "Bolder",
      "size": "Medium",
      "wrap": true
    },
    {
      "type": "TextBlock",
      "text": "Please review the details below and confirm your request.",
      "wrap": true,
      "isSubtle": true,
      "spacing": "Small"
    },
    {
      "type": "FactSet",
      "facts": [
        { "title": "Employee", "value": "${employeeName}" },
        { "title": "Type", "value": "${leaveType}" },
        { "title": "From", "value": "${leaveStartDate}" },
        { "title": "To", "value": "${leaveEndDate}" },
        { "title": "Days", "value": "${leaveDays}" }
      ],
      "spacing": "Medium"
    }
  ],
  "actions": [
    {
      "type": "Action.Submit",
      "title": "Yes, submit",
      "style": "positive",
      "data": { "action": "confirm" }
    },
    {
      "type": "Action.Submit",
      "title": "No, go back",
      "data": { "action": "cancel" }
    }
  ]
}
```

---

## Targeted Prompt: Generate card from an action response

```
I have a Power Platform connector action that returns this JSON response:
[PASTE SAMPLE JSON RESPONSE]

Generate an Adaptive Card (schema 1.5, Teams-compatible) that displays the key fields 
from this response in a readable format.

Rules:
- Use FactSet for key-value pairs
- Use TextBlock for longer text fields
- Omit null or empty fields using $when
- No action buttons needed — this is a display-only result card
- Keep it concise — max 6-8 facts visible without scrolling
```

---

## Channel Compatibility Notes

| Feature | Teams | Copilot for M365 | Web Chat |
|---------|-------|-----------------|----------|
| `Action.Submit` | ✅ | ✅ | ✅ |
| `Action.OpenUrl` | ✅ | ✅ | ✅ |
| `Input.Text` | ✅ | ✅ | ✅ |
| `Input.Date` | ✅ | ✅ | ✅ |
| Schema v1.5 features | ✅ | ✅ | ⚠️ v1.2 only |
| `$when` conditionals | ✅ | ✅ | ✅ |

Always test generated cards in the target channel using the [Adaptive Cards Designer](https://adaptivecards.io/designer/).
