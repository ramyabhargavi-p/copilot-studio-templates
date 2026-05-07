# Out of Scope Topic

**Trigger:** `OnRecognizedIntent` (triggered by out-of-scope intent phrases)
**Telemetry:** `Agent.OutOfScope`

Redirects users asking questions outside the agent's configured domain. Logs every out-of-scope attempt so you can identify gaps in scope definition.

## Files

| File | Purpose |
|------|---------|
| `OutOfScope.topic.mcs.yml` | Redirect message + `Agent.OutOfScope` telemetry |

## Quick start

```bash
cp components/topics/out-of-scope/OutOfScope.topic.mcs.yml \
   agents/<your-agent>/topics/OutOfScope.topic.mcs.yml
```

Replace `<REDIRECT_RESOURCE>` with the correct resource to direct users to (e.g., "contact HR directly at hr@contoso.com").

**When to monitor:** High `Agent.OutOfScope` rates suggest either missing topics or users trying to use the agent for unintended purposes — review the logged queries and decide whether to expand scope or reinforce the system prompt.
