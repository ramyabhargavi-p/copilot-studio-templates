# out-of-scope — Out of Scope Topic

Returns a helpful redirect message when users ask questions outside the agent's domain, and logs every attempt for monitoring.

> **Already in base/:** `base/topics/OutOfScope.topic.mcs.yml` ships with every agent. If you started from `base/`, configure that file directly — do not copy this one. Use this folder as a reference for the placeholder table and examples.

---

## When to use

Every agent needs out-of-scope handling. Configure the file already in your agent at `topics/OutOfScope.topic.mcs.yml`:

1. Add 3–5 specific trigger phrases for your agent's known out-of-scope areas
2. Replace `<DOMAIN>`, `<OUT-OF-SCOPE-TOPIC>`, and `<CONTACT>` in the message

## Placeholders

| Placeholder | Line | Example (HR Assistant) |
|---|---|---|
| `<out-of-scope phrase 1–5>` | 24–28 | `payroll`, `expense reimbursement`, `IT support`, `office supplies` |
| `<DOMAIN>` | 48 | `HR policies` |
| `<OUT-OF-SCOPE-TOPIC>` | 48 | `IT support` |
| `<CONTACT>` | 49 | `it@contoso.com` |
| `_REPLACE1–2` | — | Run ID script |

> **Node IDs:** Replace every `_REPLACE` suffix with a unique string before use — see [QUICKSTART.md → Replace node IDs](../../../docs/QUICKSTART.md).

## Before → after

```yaml
# Before
triggerQueries:
  - <out-of-scope phrase 1>
  - <out-of-scope phrase 2>
  - <out-of-scope phrase 3>

# After (HR Assistant example)
triggerQueries:
  - payroll query
  - expense reimbursement
  - IT support
  - office supplies
  - facilities request
```

```yaml
# Before — response text
- "I'm only able to help with <DOMAIN>. For <OUT-OF-SCOPE-TOPIC>, <CONTACT> would be your best bet."

# After
- "I'm only able to help with HR policies. For IT support, it@contoso.com would be your best bet."
```

## Two-layer out-of-scope strategy

This topic catches **known** out-of-scope areas via explicit trigger phrases. For the long tail of unexpected queries, reinforce in the system prompt:

```yaml
# In agent.mcs.yml instructions:
## Handling out-of-scope questions
If a user asks about something outside HR policies and leave management,
respond: "I'm only set up to help with HR queries. For [topic], please contact [resource]."
Never attempt to answer out-of-scope questions.
```

## Monitoring

High `Agent.OutOfScope` rates in App Insights indicate users are trying to use the agent for unintended purposes, or scope is too narrow. Review the logged `UserQuery` values and decide whether to expand scope or reinforce the system prompt.

→ KQL queries for out-of-scope events: [`../../../operations/02-monitoring-queries.md`](../../../operations/02-monitoring-queries.md)
