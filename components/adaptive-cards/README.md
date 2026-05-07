# Adaptive Card Templates

6 card JSON templates. Reference these inline inside topic YAML via `SendActivity` nodes.

---

## Cards

| File | Use case | When to use |
|------|---------|-------------|
| `confirmation-card.json` | Confirm or cancel before executing an action | **Required** for Medium and High safety tier actions |
| `status-card.json` | Display action result with status colour (success / warning / error) | After any write operation completes |
| `form-card.json` | Collect structured input — text, date, dropdown | When you need multiple inputs in one step |
| `feedback-thumbs.json` | 👍 / 👎 binary satisfaction | First step of the Feedback topic |
| `feedback-rating.json` | 1–5 star rating | Second step of the Feedback topic |
| `feedback-text.json` | Free text comment + issue category | Third step of the Feedback topic |

---

## Usage

Cards are embedded in topic YAML as an `activity.attachments` value. Copy the JSON content and paste it into the `SendActivity` node in your topic.

The Feedback topic (`components/topics/feedback/`) already wires up the three feedback cards — you do not need to add them manually if you use that component.

→ Action safety tiers and when confirmation is required: [`../../ACTION-SAFETY-PATTERNS.md`](../../ACTION-SAFETY-PATTERNS.md)
