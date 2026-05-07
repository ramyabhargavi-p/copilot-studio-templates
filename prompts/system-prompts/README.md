# System Prompt Templates

Ready-made agent personas. Paste the contents of one of these files into the `instructions` field in your `agent.mcs.yml`.

| File | Agent type |
|------|-----------|
| `it-helpdesk.md` | IT support — password resets, hardware issues, service desk |
| `hr-assistant.md` | HR — leave policies, benefits, onboarding |
| `customer-support.md` | External-facing customer service |
| `knowledge-base.md` | Generic internal knowledge base assistant |

Each template follows the standard structure:
- Who you are (1–2 sentences)
- What you can help with (in-scope list)
- What you cannot help with (out-of-scope with redirect text)
- Response quality guidelines
- Escalation instructions

→ Prompt engineering patterns: [`../ai-prompts/prompt-engineering-patterns.md`](../ai-prompts/prompt-engineering-patterns.md)
→ Generate a custom prompt: [`../ai-prompts/generate-agent-instructions.md`](../ai-prompts/generate-agent-instructions.md)
