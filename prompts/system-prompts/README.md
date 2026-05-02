# System Prompt Templates

Ready-to-use `instructions` content for `agent.mcs.yml`. Each template is a complete, production-quality system prompt for a specific agent archetype.

## How to Use

1. Open the relevant template file
2. Copy the content inside the code block
3. Paste into `agent.mcs.yml` → `instructions`
4. Replace every `[BRACKET]` value with your specifics
5. Add the recommended components listed at the bottom of each template

## Templates

| File | Agent type | Auth mode |
|------|-----------|-----------|
| [`hr-assistant.md`](hr-assistant.md) | HR queries — leave, policies, onboarding | ManualAzureAD |
| [`it-helpdesk.md`](it-helpdesk.md) | IT support — passwords, software, troubleshooting | IntegratedAzureAD (Teams) |
| [`customer-support.md`](customer-support.md) | External customer support — orders, returns, accounts | None or ManualAzureAD |
| [`knowledge-base.md`](knowledge-base.md) | Internal knowledge / FAQ — answers from documents | None or IntegratedAzureAD |

## Writing Your Own

Every system prompt should include these sections in order:

```
1. Current Context (date + user name — always include)
2. What I am (role + domain, 1-2 sentences)
3. What I can help with (in-scope list — be specific)
4. What I cannot help with (out-of-scope list + redirect targets)
5. Handling out-of-scope (verbatim redirect message)
6. Response quality (tone, format, length)
7. [Domain-specific rules] (optional but important for complex domains)
8. Escalation (when and what to say)
```

The most common mistake: writing only sections 1-2 and skipping 4-8. An agent without explicit out-of-scope rules and escalation guidance will fail in production.
