# Variable Components

Global variable declarations for sharing state across topics within a conversation.

## Available Variable Components

| Component | Scope | What it does |
|-----------|-------|-------------|
| [`global-variable/`](global-variable/) | Conversation | Shared state across all topics (user profile, locale, flags) |

## When to Use Global Variables

Use global variables when:
- Multiple topics need access to the same data (e.g., `Global.UserDisplayName` in greeting, escalation, and knowledge search)
- You want to set a value once (e.g., in `conversation-init`) and read it everywhere
- You need to pass state between topics without using `BeginDialog` output parameters

**Keep globals minimal.** Only promote a variable to global scope if 2+ topics genuinely need it. Everything else should be a `Topic.` variable.

## Common Global Variables (from `conversation-init`)

| Variable | Type | Set by | Used by |
|----------|------|--------|---------|
| `Global.UserDisplayName` | Text | `conversation-init` | Greeting, Escalation, system prompt |
| `Global.UserCountry` | Text | `conversation-init` | System prompt, any topic needing locale |

See the `conversation-init` component (`components/topics/conversation-init/`) for how these are populated.
