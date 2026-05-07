# Global Variable Components

5 global variable templates. Variables declared here are available across all topics in the agent.

---

## Variables

| Folder | Variable name | Scope | Loaded by |
|--------|--------------|-------|-----------|
| [`global-variable/`](global-variable/) | Configurable | Conversation | Any topic |
| [`user-display-name/`](user-display-name/) | `Global.UserDisplayName` | Conversation | `conversation-init` topic |
| [`user-country/`](user-country/) | `Global.UserCountry` | Conversation | `conversation-init` topic |
| [`glossary-var/`](glossary-var/) | `Global.Glossary` | Conversation | `conversation-init` topic |

---

## When to use global variables

Use a global variable when a value:
- Is set once (e.g., on conversation start) and read by multiple topics
- Should be injected into the agent's system prompt via Power Fx (e.g., `{Global.UserDisplayName}`)
- Controls conversation-wide state (e.g., `Global.IsAuthenticated`)

For values used only within a single topic, use `Topic.` variables instead.

```bash
cp components/variables/global-variable/global-variable.variable.mcs.yml \
   agents/<your-agent>/variables/<VariableName>.variable.mcs.yml
```

→ How `UserDisplayName` and `UserCountry` are loaded: [`../topics/conversation-init/README.md`](../topics/conversation-init/README.md)
→ Generic variable template: [`global-variable/README.md`](global-variable/README.md)
